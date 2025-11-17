class User {
  final int? id;
  final String username;
  final String password; // Will be hashed
  final String name;
  final String email;
  final String? photoPath;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert User to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'email': email,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoPath: map['photoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? name,
    String? email,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email)';
  }
}
