import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/repositories/auth_repository.dart';
import 'package:washify/core/utils/session_service.dart';
import 'package:washify/core/utils/hash_util.dart';
import 'package:washify/repositories/audit_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository, {AppUser? initialUser})
      : super(initialUser);

  /// Converts phone to a fake email for Firebase Auth
  String _phoneToEmail(String phone) {
    return '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@washify.app';
  }

  Future<bool> login(String phone, String pin) async {
    try {
      final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final password = hashPin(pin);

      // Step 1: ALWAYS query Firestore first to get the active user
      final user = await _authRepository.getUserByPhone(sanitizedPhone);
      
      if (user == null || !user.isActive) {
        return false;
      }

      // Step 2: Verify PIN
      if (user.pinHash != password) {
        return false;
      }

      // Step 3: Use the user ID to create a unique Firebase Auth email
      final email = '${user.id}@washify.app';

      // Step 4: Try Firebase Auth sign-in
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      } on FirebaseAuthException {
        // Step 5: If it fails (e.g. first time logging in with this ID, or migrating from old phone-based email), create the account
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password);
        } catch (createError) {
          print('Could not create Firebase Auth account: $createError');
          return false;
        }
      }

      // Step 6: Check station suspension (now authenticated, can read stations)
      if (user.tenantId.isNotEmpty && user.tenantId != 'admin_station') {
        try {
          final stationDoc = await FirebaseFirestore.instance
            .collection('stations').doc(user.tenantId).get();
          if (stationDoc.exists) {
            final stationData = stationDoc.data()!;
            if (stationData['licence'] == 'suspended') {
              await FirebaseAuth.instance.signOut();
              throw Exception('station_suspended');
            }
          }
        } catch (e) {
          if (e.toString().contains('station_suspended')) rethrow;
        }
      }

      state = user;
      await SessionService.instance.saveSession(user.id);
      
      try {
        // Update online status in Firestore
        await _authRepository.updateOnlineStatus(user.id, true);
        
        // Log connection
        AuditRepository().log(
          userId: user.id,
          userName: user.name,
          action: 'login',
          module: 'auth',
          description: 'Connexion réussie',
          stationId: user.tenantId,
        );
      } catch (logError) {
        print('Error updating online status or audit log: $logError');
      }

      return true;
    } catch (e) {
      print('Network or login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    if (state != null) {
      try {
        await _authRepository.updateOnlineStatus(state!.id, false);
        
        await AuditRepository().log(
          userId: state!.id,
          userName: state!.name,
          action: 'logout',
          module: 'auth',
          description: 'Déconnexion',
          stationId: state!.tenantId,
        );
      } catch (e) {
        print('Audit/Status logout failed: $e');
      }
    }
    state = null;
    await SessionService.instance.clearSession();
    await FirebaseAuth.instance.signOut();
  }

  void updateUser(AppUser user) {
    state = user;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (state != null) {
      try {
        final hashedOldPin = hashPin(oldPin);
        if (state!.pinHash != hashedOldPin) {
          return false; // Old PIN is incorrect
        }
        // Update Firestore
        await _authRepository.changePin(state!.id, newPin);

        // Update Firebase Auth password
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email != null) {
          try {
            final credential = EmailAuthProvider.credential(
              email: currentUser.email!, password: hashedOldPin);
            await currentUser.reauthenticateWithCredential(credential);
            await currentUser.updatePassword(hashPin(newPin));
          } catch (e) {
            print('Warning: Firebase Auth password update failed: $e');
            // Firestore is already updated, this is not critical
          }
        }

        // Update local state with new pin hash
        state = state!.copyWith(pinHash: hashPin(newPin));
        return true;
      } catch (e) {
        print('Error changing pin: $e');
        return false;
      }
    }
    return false;
  }
}

/// Initializes everything required before the app shows.
/// 1. Ensures admin exists
/// 2. Restores session if available and returns the restored AppUser
final appInitProvider = FutureProvider<AppUser?>((ref) async {
  print('TRACE: appInitProvider started');
  final authRepo = ref.read(authRepositoryProvider);
  
  // 1. Ensure admin exists
  print('TRACE: Calling ensureAdminExists');
  await authRepo.ensureAdminExists();
  print('TRACE: ensureAdminExists finished');
  
  // 2. Restore session
  print('TRACE: Getting saved user ID');
  final savedUserId = SessionService.instance.getSavedUserId();
  print('TRACE: savedUserId = $savedUserId');
  
  if (savedUserId != null && savedUserId.isNotEmpty) {
    try {
      print('TRACE: Calling getUserById');
      if (FirebaseAuth.instance.currentUser == null) {
        print('TRACE: Firebase Auth is null, clearing session');
        await SessionService.instance.clearSession();
        return null;
      }
      final user = await authRepo.getUserById(savedUserId);
      print('TRACE: getUserById finished');
      if (user != null && user.isActive) {
        return user;
      } else {
        await SessionService.instance.clearSession();
      }
    } catch (e) {
      print('TRACE: Error in restore session: $e');
      await SessionService.instance.clearSession();
    }
  }
  print('TRACE: appInitProvider finished returning null');
  return null;
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AppUser?>((ref) {
  // We read the synchronous value from appInitProvider to seed the state.
  // Because routerProvider only watches currentUserProvider, it needs the user.
  final initialUser = ref.read(appInitProvider).valueOrNull;
  return CurrentUserNotifier(ref.watch(authRepositoryProvider), initialUser: initialUser);
});

final stationUsersProvider = FutureProvider.family<List<AppUser>, String>((ref, stationId) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getUsersByStationId(stationId);
});

/// Streams the real-time document of the currently logged in user
final userRealtimeProvider = StreamProvider<AppUser?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const Stream.empty();
  
  final repo = ref.watch(authRepositoryProvider);
  return repo.userStream(currentUser.id);
});


