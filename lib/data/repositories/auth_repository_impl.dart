import '../../core/utils/app_error_handler.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await remoteDataSource.signInWithEmail(email, password);
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<UserEntity> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    try {
      return await remoteDataSource.signUpWithEmail(
        email,
        password,
        name,
        username,
      );
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.updatePassword(currentPassword, newPassword);
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      await remoteDataSource.deleteAccount(password);
    } catch (e) {
      final result = AppErrorHandler.handleError(e);
      throw Exception(result.message);
    }
  }
}
