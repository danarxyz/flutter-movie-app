import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? profileImageUrl;
  final String role;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.profileImageUrl,
    this.role = 'user',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, 
    email, 
    name, 
    username, 
    profileImageUrl, 
    role,
    createdAt,
  ];
}

