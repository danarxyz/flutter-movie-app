import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network utility class for handling connectivity checks and timeouts
class NetworkUtils {
  static const Duration defaultTimeout = Duration(seconds: 15);

  /// Check if device has any network connection
  static Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Execute a future with network check and timeout
  /// Throws [NetworkException] if no connection or timeout
  static Future<T> executeWithNetworkCheck<T>({
    required Future<T> Function() operation,
    Duration timeout = defaultTimeout,
  }) async {
    // Check connectivity first
    if (!await hasConnection()) {
      throw NetworkException(
        'No internet connection. Please check your network settings.',
        type: NetworkExceptionType.noConnection,
      );
    }

    // Execute with timeout
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          throw NetworkException(
            'Connection timeout. Please try again.',
            type: NetworkExceptionType.timeout,
          );
        },
      );
    } on TimeoutException {
      throw NetworkException(
        'Connection timeout. Please try again.',
        type: NetworkExceptionType.timeout,
      );
    }
  }
}

enum NetworkExceptionType { noConnection, timeout }

class NetworkException implements Exception {
  final String message;
  final NetworkExceptionType type;

  NetworkException(this.message, {required this.type});

  @override
  String toString() => message;
}
