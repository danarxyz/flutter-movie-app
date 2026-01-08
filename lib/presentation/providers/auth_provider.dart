import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// State for Authentication
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AuthState({this.user, this.isLoading = false, this.error, this.successMessage});

  AuthState copyWith({UserEntity? user, bool isLoading = false, String? error, String? successMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

// Controller/Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    // initial check
    final user = await _repository.getCurrentUser();
    if (user != null) {
        state = AuthState(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String username, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.register(name, username, email, password);
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState();
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(email);
      state = state.copyWith(isLoading: false, successMessage: 'Password reset email sent!');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({String? displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProfile(displayName: displayName);
      // Refresh user data
      final updatedUser = await _repository.getCurrentUser();
      state = AuthState(user: updatedUser, successMessage: 'Profile updated successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false, successMessage: 'Password changed successfully!');
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('wrong-password') || errorMessage.contains('invalid-credential')) {
        errorMessage = 'Current password is incorrect';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'New password is too weak';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAccount(password);
      state = const AuthState();
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('wrong-password') || errorMessage.contains('invalid-credential')) {
        errorMessage = 'Password is incorrect';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) => sl<AuthRepository>());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

