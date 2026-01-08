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
    return await remoteDataSource.signInWithEmail(email, password);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity> register(String name, String username, String email, String password) async {
    return await remoteDataSource.signUpWithEmail(email, password, name, username);
  }

  @override
  Future<void> resetPassword(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await remoteDataSource.updateProfile(displayName: displayName, photoUrl: photoUrl);
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    await remoteDataSource.updatePassword(currentPassword, newPassword);
  }

  @override
  Future<void> deleteAccount(String password) async {
    await remoteDataSource.deleteAccount(password);
  }
}

