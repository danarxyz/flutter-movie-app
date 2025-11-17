import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Login user
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dbHelper.loginUser(username, password);

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register user (optimized with transaction, no race condition)
  Future<bool> register({
    required String username,
    required String password,
    required String name,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create new user
      final user = User(
        username: username,
        password: password,
        name: name,
        email: email,
      );

      // registerUser now uses transaction internally (atomic check + insert)
      final userId = await _dbHelper.registerUser(user);

      if (userId > 0) {
        // Auto login after registration
        final registeredUser = await _dbHelper.getUserById(userId);
        _currentUser = registeredUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mendaftar. Silakan coba lagi';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle duplicate username error from transaction
      if (e.toString().contains('Username sudah terdaftar')) {
        _errorMessage = 'Username sudah terdaftar';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
      );

      final result = await _dbHelper.updateUser(updatedUser);

      if (result > 0) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user photo
  Future<bool> updatePhoto(String photoPath) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _dbHelper.updateUserPhoto(_currentUser!.id!, photoPath);

      if (result > 0) {
        _currentUser = _currentUser!.copyWith(photoPath: photoPath);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal update foto';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change password (optimized with atomic transaction)
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use atomic transaction: verify + update in one database lock
      final result = await _dbHelper.updateUserPasswordWithVerification(
        _currentUser!.id!,
        oldPassword,
        newPassword,
      );

      if (result) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal update password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Handle password verification error from transaction
      if (e.toString().contains('Password lama salah')) {
        _errorMessage = 'Password lama salah';
      } else {
        _errorMessage = 'Error: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
