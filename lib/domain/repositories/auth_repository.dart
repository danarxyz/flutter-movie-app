import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with Email & Password
  Future<UserEntity> login(String email, String password);

  /// Register new user
  Future<UserEntity> register(String name, String username, String email, String password);

  /// Sign out
  Future<void> logout();

  /// Get currently logged in user (if any)
  Future<UserEntity?> getCurrentUser();
  
  /// Reset password flow
  Future<void> resetPassword(String email);

  /// Update user profile (display name, photo)
  Future<void> updateProfile({String? displayName, String? photoUrl});

  /// Change password
  Future<void> updatePassword(String currentPassword, String newPassword);

  /// Delete account
  Future<void> deleteAccount(String password);
}

