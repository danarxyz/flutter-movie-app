/// Custom exceptions for error handling across the application.
///
/// These exceptions are thrown by data layer implementations and
/// caught by use cases or providers for appropriate error handling.

/// Base exception class for all app-specific exceptions.
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException(this.message, [this.originalError]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when watchlist operations fail.
class WatchlistException extends AppException {
  const WatchlistException(super.message, [super.originalError]);
}

/// Exception thrown when network operations fail.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.originalError]);
}

/// Exception thrown when cache/local storage operations fail.
class CacheException extends AppException {
  const CacheException(super.message, [super.originalError]);
}

/// Exception thrown when authentication operations fail.
class AuthException extends AppException {
  const AuthException(super.message, [super.originalError]);
}
