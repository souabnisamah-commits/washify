import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/repositories/auth_repository.dart';
import 'package:washify/core/utils/session_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository, {AppUser? initialUser})
      : super(initialUser);

  Future<bool> login(String phone, String pin) async {
    final user = await _authRepository.loginWithPhoneAndPin(phone, pin);
    if (user != null) {
      state = user;
      await SessionService.instance.saveSession(user.id);
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
    SessionService.instance.clearSession();
  }

  void updateUser(AppUser user) {
    state = user;
  }

  Future<void> changePin(String newPin) async {
    if (state != null) {
      await _authRepository.changePin(state!.id, newPin);
    }
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


