import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../core/utils/network_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_management_repository.dart';

/// Provider for the UserManagementRepository
final userManagementRepositoryProvider = Provider<UserManagementRepository>(
  (ref) => sl<UserManagementRepository>(),
);

/// Stream provider for all users
final allUsersProvider = StreamProvider<List<UserEntity>>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return repository.getAllUsers();
});

/// State for user management operations
class UserManagementState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const UserManagementState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  UserManagementState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for user management operations
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final UserManagementRepository _repository;

  UserManagementNotifier(this._repository) : super(const UserManagementState());

  /// Parse Firebase errors into user-friendly messages
  String _parseError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission denied') ||
        errorString.contains('permission_denied')) {
      return 'Permission denied. You don\'t have access to perform this action.';
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('not found') ||
        errorString.contains('does not exist')) {
      return 'User not found. They may have been deleted.';
    }

    if (errorString.contains('already exists') ||
        errorString.contains('duplicate')) {
      return 'This user already exists.';
    }

    if (errorString.contains('invalid') || errorString.contains('malformed')) {
      return 'Invalid data provided. Please check your input.';
    }

    // Fallback: return a cleaned up version of the error
    return 'Operation failed. Please try again.';
  }

  Future<bool> createUser(UserEntity user) async {
    state = state.copyWith(isLoading: true);
    try {
      await NetworkUtils.executeWithNetworkCheck(
        operation: () => _repository.createUser(user),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User created successfully!',
      );
      return true;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> updateUser(UserEntity user) async {
    state = state.copyWith(isLoading: true);
    try {
      await NetworkUtils.executeWithNetworkCheck(
        operation: () => _repository.updateUser(user),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User updated successfully!',
      );
      return true;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      await NetworkUtils.executeWithNetworkCheck(
        operation: () => _repository.deleteUser(userId),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User deleted successfully!',
      );
      return true;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      await NetworkUtils.executeWithNetworkCheck(
        operation: () => _repository.updateUserRole(userId, role),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User role updated!',
      );
      return true;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Provider for user management operations
final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
      return UserManagementNotifier(
        ref.watch(userManagementRepositoryProvider),
      );
    });
