import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'movie_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        photoPath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Insert default admin user
    final adminPassword = _hashPassword('admin123');
    await db.insert('users', {
      'username': 'admin',
      'password': adminPassword,
      'name': 'Administrator',
      'email': 'admin@movieapp.com',
      'photoPath': null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user with transaction (atomic check + insert)
  Future<int> registerUser(User user) async {
    final db = await database;
    final hashedPassword = _hashPassword(user.password);
    final userWithHashedPassword = user.copyWith(password: hashedPassword);

    // Use transaction to ensure atomic operation
    return await db.transaction((txn) async {
      // Check if username exists within the transaction
      final List<Map<String, dynamic>> existing = await txn.query(
        'users',
        where: 'username = ?',
        whereArgs: [user.username],
      );

      if (existing.isNotEmpty) {
        throw Exception('Username sudah terdaftar');
      }

      // Insert user within the same transaction
      return await txn.insert('users', userWithHashedPassword.toMap());
    });
  }

  // Login user
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  // Get user by id
  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Update user password with verification (atomic verify + update)
  Future<bool> updateUserPasswordWithVerification(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final db = await database;
    final oldHashedPassword = _hashPassword(oldPassword);
    final newHashedPassword = _hashPassword(newPassword);

    // Use transaction for atomic verify + update
    return await db.transaction((txn) async {
      // Verify old password within transaction
      final List<Map<String, dynamic>> maps = await txn.query(
        'users',
        where: 'id = ? AND password = ?',
        whereArgs: [userId, oldHashedPassword],
      );

      if (maps.isEmpty) {
        throw Exception('Password lama salah');
      }

      // Update password within the same transaction
      final result = await txn.update(
        'users',
        {'password': newHashedPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return result > 0;
    });
  }

  // Update user password (simple update without verification)
  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await database;
    final hashedPassword = _hashPassword(newPassword);
    return await db.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Update user photo
  Future<int> updateUserPhoto(int userId, String photoPath) async {
    final db = await database;
    return await db.update(
      'users',
      {'photoPath': photoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
