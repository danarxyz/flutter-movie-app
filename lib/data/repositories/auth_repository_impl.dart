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
  Future<UserEntity> register(String name, String email, String password) async {
    return await remoteDataSource.signUpWithEmail(email, password, name);
  }

  @override
  Future<void> resetPassword(String email) async {
    // TODO: Implement reset password in data source and here
    throw UnimplementedError();
  }
}
