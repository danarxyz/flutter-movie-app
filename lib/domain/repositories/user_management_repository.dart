import '../entities/user_entity.dart';

/// Repository interface for user management operations
abstract class UserManagementRepository {
  /// Get all users as a stream
  Stream<List<UserEntity>> getAllUsers();
  
  /// Get a single user by ID
  Future<UserEntity?> getUserById(String userId);
  
  /// Create a new user profile
  Future<void> createUser(UserEntity user);
  
  /// Update an existing user
  Future<void> updateUser(UserEntity user);
  
  /// Delete a user
  Future<void> deleteUser(String userId);
  
  /// Update user role
  Future<void> updateUserRole(String userId, String role);
}
