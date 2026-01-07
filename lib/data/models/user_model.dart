import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.profileImageUrl,
    super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['displayName'] ?? map['name'] ?? '',
      profileImageUrl: map['photoUrl'] ?? map['profileImageUrl'],
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'role': role,
    };
  }
}
