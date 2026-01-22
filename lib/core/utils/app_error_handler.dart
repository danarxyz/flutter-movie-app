// Global error handler untuk semua jenis error di aplikasi.
//
// Centralized error handling dengan categorization untuk
// memberikan pesan user-friendly dalam Bahasa Indonesia.

/// Kategori error untuk grouping dan handling berbeda di UI
enum ErrorCategory {
  network, // No internet, timeout, connection errors
  auth, // Login, signup, password errors
  server, // API errors, Firebase errors
  validation, // Input validation errors
  unknown, // Fallback for unhandled errors
}

/// Result dari error handling berisi message dan category
class ErrorResult {
  final String message;
  final ErrorCategory category;

  const ErrorResult(this.message, this.category);
}

/// Central error handler yang bisa digunakan di semua screen
class AppErrorHandler {
  /// Handle any error dan return user-friendly message + category
  static ErrorResult handleError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // 1. Network Errors - prioritas tertinggi
    if (_isNetworkError(errorString)) {
      return const ErrorResult(
        'Tidak ada koneksi internet. Silakan cek koneksi Anda.',
        ErrorCategory.network,
      );
    }

    // 2. Auth Errors
    if (_isAuthError(errorString)) {
      return ErrorResult(_getAuthErrorMessage(errorString), ErrorCategory.auth);
    }

    // 3. Server/Firebase Errors
    if (_isServerError(errorString)) {
      return ErrorResult(
        _getServerErrorMessage(errorString),
        ErrorCategory.server,
      );
    }

    // 4. Validation Errors
    if (_isValidationError(errorString)) {
      return ErrorResult(
        _getValidationErrorMessage(errorString),
        ErrorCategory.validation,
      );
    }

    // Fallback
    return const ErrorResult(
      'Terjadi kesalahan. Silakan coba lagi.',
      ErrorCategory.unknown,
    );
  }

  /// Check if error is network related
  static bool _isNetworkError(String error) {
    return error.contains('socketexception') ||
        error.contains('network') ||
        error.contains('timeout') ||
        error.contains('connection refused') ||
        error.contains('connection reset') ||
        error.contains('no internet') ||
        error.contains('network-request-failed') ||
        error.contains('failed host lookup');
  }

  /// Check if error is authentication related
  static bool _isAuthError(String error) {
    return error.contains('wrong-password') ||
        error.contains('invalid-credential') ||
        error.contains('user-not-found') ||
        error.contains('email-already-in-use') ||
        error.contains('weak-password') ||
        error.contains('invalid-email') ||
        error.contains('too-many-requests') ||
        error.contains('username already taken') ||
        error.contains('username not found') ||
        error.contains('user data not found') ||
        error.contains('email not found') ||
        error.contains('not logged in') ||
        error.contains('requires-recent-login');
  }

  /// Get user-friendly message for auth errors
  static String _getAuthErrorMessage(String error) {
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Password salah. Silakan coba lagi.';
    }
    if (error.contains('user-not-found')) {
      return 'Email tidak terdaftar.';
    }
    if (error.contains('email-already-in-use')) {
      return 'Email sudah digunakan. Silakan gunakan email lain.';
    }
    if (error.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    }
    if (error.contains('invalid-email')) {
      return 'Format email tidak valid.';
    }
    if (error.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi dalam beberapa menit.';
    }
    if (error.contains('username already taken')) {
      return 'Username sudah digunakan. Pilih username lain.';
    }
    if (error.contains('username not found')) {
      return 'Username tidak ditemukan.';
    }
    if (error.contains('user data not found') ||
        error.contains('email not found')) {
      return 'Data pengguna tidak ditemukan.';
    }
    if (error.contains('not logged in')) {
      return 'Silakan login terlebih dahulu.';
    }
    if (error.contains('requires-recent-login')) {
      return 'Sesi telah berakhir. Silakan login ulang.';
    }
    return 'Autentikasi gagal. Silakan coba lagi.';
  }

  /// Check if error is server related
  static bool _isServerError(String error) {
    return error.contains('500') ||
        error.contains('502') ||
        error.contains('503') ||
        error.contains('504') ||
        error.contains('internal server') ||
        error.contains('permission-denied') ||
        error.contains('unavailable') ||
        error.contains('firebase') && error.contains('error');
  }

  /// Get user-friendly message for server errors
  static String _getServerErrorMessage(String error) {
    if (error.contains('permission-denied')) {
      return 'Anda tidak memiliki akses. Silakan hubungi admin.';
    }
    if (error.contains('unavailable')) {
      return 'Server sedang tidak tersedia. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan server. Coba lagi nanti.';
  }

  /// Check if error is validation related
  static bool _isValidationError(String error) {
    return error.contains('invalid') ||
        error.contains('required') ||
        error.contains('must be') ||
        error.contains('cannot be empty');
  }

  /// Get user-friendly message for validation errors
  static String _getValidationErrorMessage(String error) {
    if (error.contains('required') || error.contains('cannot be empty')) {
      return 'Mohon lengkapi semua data yang diperlukan.';
    }
    return 'Data yang dimasukkan tidak valid.';
  }
}
