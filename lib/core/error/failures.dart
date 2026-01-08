import 'package:equatable/equatable.dart';

/// Abstract class representing a failure in the application.
///
/// Failures are used in the domain layer to represent error states
/// without exposing implementation details (exceptions) from the data layer.
/// Use with dartz's Either for functional error handling.
abstract class Failure extends Equatable {
  final String message;
  final dynamic originalError;

  const Failure({required this.message, this.originalError});

  @override
  List<Object?> get props => [message, originalError];
}

/// Failure from server/API errors.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.originalError});
}

/// Failure from local cache/storage errors.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.originalError});
}

/// Failure from network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.originalError});
}

/// Failure from watchlist operations.
class WatchlistFailure extends Failure {
  const WatchlistFailure({required super.message, super.originalError});
}

/// Failure from authentication operations.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.originalError});
}
