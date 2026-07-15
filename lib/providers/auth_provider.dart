import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/repositories/auth_repository.dart';
import 'package:washify/core/utils/session_service.dart';
import 'package:washify/core/utils/hash_util.dart';

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
      final email = _phoneToEmail(phone);
      final password = hashPin(pin);

      // Step 1: Try Firebase Auth sign-in
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      } on FirebaseAuthException catch (authError) {
        // Step 2: Firebase Auth failed - try migration via Firestore
        final verifiedUser = await _authRepository.loginWithPhoneAndPin(phone, pin);
        if (verifiedUser == null) return false; // Wrong credentials

        // Step 3: PIN verified in Firestore, create Firebase Auth account
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: password);
        } catch (createError) {
          print('Migration: Could not create Firebase Auth account: $createError');
          // If account exists with different password, try updating
          return false;
        }
      }

      // Step 4: Now authenticated, load user data from Firestore
      final user = await _authRepository.getUserByPhone(phone);
      if (user != null && user.isActive) {
        state = user;
        await SessionService.instance.saveSession(user.id);
        return true;
      }

      await FirebaseAuth.instance.signOut();
      return false;
    } catch (e) {
      print('Network or login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
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


