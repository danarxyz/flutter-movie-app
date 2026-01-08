import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';

/// Data source for user management operations (CRUD)
/// Uses Firebase Realtime Database to store user profiles
abstract class UserManagementDataSource {
  /// Get all users
  Stream<List<UserModel>> getAllUsers();
  
  /// Get a single user by ID
  Future<UserModel?> getUserById(String userId);
  
  /// Create a new user profile in the database
  Future<void> createUserProfile(UserModel user);
  
  /// Update an existing user profile
  Future<void> updateUserProfile(UserModel user);
  
  /// Delete a user profile
  Future<void> deleteUserProfile(String userId);
  
  /// Update user role
  Future<void> updateUserRole(String userId, String role);
}

class UserManagementDataSourceImpl implements UserManagementDataSource {
  final FirebaseDatabase firebaseDatabase;
  
  UserManagementDataSourceImpl({required this.firebaseDatabase});
  
  DatabaseReference get _usersRef => firebaseDatabase.ref('users');
  
  @override
  Stream<List<UserModel>> getAllUsers() {
    return _usersRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        final userData = Map<String, dynamic>.from(entry.value as Map);
        userData['id'] = entry.key;
        return UserModel.fromMap(userData);
      }).toList();
    });
  }
  
  @override
  Future<UserModel?> getUserById(String userId) async {
    final snapshot = await _usersRef.child(userId).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    
    final userData = Map<String, dynamic>.from(snapshot.value as Map);
    userData['id'] = userId;
    return UserModel.fromMap(userData);
  }
  
  @override
  Future<void> createUserProfile(UserModel user) async {
    await _usersRef.child(user.id).set(user.toMap());
  }
  
  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _usersRef.child(user.id).update(user.toMap());
  }
  
  @override
  Future<void> deleteUserProfile(String userId) async {
    await _usersRef.child(userId).remove();
  }
  
  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _usersRef.child(userId).update({'role': role});
  }
}
