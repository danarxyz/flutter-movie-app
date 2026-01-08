import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/firebase/user_management_data_source.dart';
import '../models/user_model.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementDataSource dataSource;
  
  UserManagementRepositoryImpl({required this.dataSource});
  
  @override
  Stream<List<UserEntity>> getAllUsers() {
    return dataSource.getAllUsers();
  }
  
  @override
  Future<UserEntity?> getUserById(String userId) async {
    return await dataSource.getUserById(userId);
  }
  
  @override
  Future<void> createUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      role: user.role,
    );
    await dataSource.createUserProfile(userModel);
  }
  
  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      role: user.role,
    );
    await dataSource.updateUserProfile(userModel);
  }
  
  @override
  Future<void> deleteUser(String userId) async {
    await dataSource.deleteUserProfile(userId);
  }
  
  @override
  Future<void> updateUserRole(String userId, String role) async {
    await dataSource.updateUserRole(userId, role);
  }
}
