import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AppUser?>((ref) {
  return CurrentUserNotifier(ref.watch(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository) : super(null);

  Future<bool> login(String phone, String pin) async {
    final user = await _authRepository.loginWithPhoneAndPin(phone, pin);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }

  void updateUser(AppUser user) {
    state = user;
  }
}

final authInitProvider = FutureProvider<void>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  await authRepo.ensureAdminExists();
});
