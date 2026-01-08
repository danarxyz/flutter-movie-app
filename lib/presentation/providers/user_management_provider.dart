import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
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
  
  Future<bool> createUser(UserEntity user) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createUser(user);
      state = state.copyWith(isLoading: false, successMessage: 'User created successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateUser(UserEntity user) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateUser(user);
      state = state.copyWith(isLoading: false, successMessage: 'User updated successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteUser(userId);
      state = state.copyWith(isLoading: false, successMessage: 'User deleted successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> updateUserRole(String userId, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateUserRole(userId, role);
      state = state.copyWith(isLoading: false, successMessage: 'User role updated!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Provider for user management operations
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier(ref.watch(userManagementRepositoryProvider));
});
