import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.username,
    super.profileImageUrl,
    super.role,
    super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['displayName'] ?? map['name'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['photoUrl'] ?? map['profileImageUrl'],
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  /// Helper: Convert to map WITHOUT id (for Firebase set)
  Map<String, dynamic> toFirebaseMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? 
                   DateTime.now().millisecondsSinceEpoch,
    };
  }
}

