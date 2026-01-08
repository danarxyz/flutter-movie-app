import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A reusable error screen widget for displaying error states.
/// 
/// Can be used for network errors, general errors, empty states, etc.
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool isNetworkError;
  final bool isFullScreen;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon,
    this.isNetworkError = false,
    this.isFullScreen = true,
  });

  /// Factory constructor for network errors
  factory ErrorScreen.noInternet({
    VoidCallback? onRetry,
    bool isFullScreen = true,
  }) {
    return ErrorScreen(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again',
      icon: Icons.wifi_off_rounded,
      isNetworkError: true,
      onRetry: onRetry,
      isFullScreen: isFullScreen,
    );
  }

  /// Factory constructor for general errors
  factory ErrorScreen.generalError({
    String? message,
    VoidCallback? onRetry,
    bool isFullScreen = true,
  }) {
    return ErrorScreen(
      title: 'Something went wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
      isFullScreen: isFullScreen,
    );
  }

  /// Factory constructor for empty states
  factory ErrorScreen.empty({
    String? title,
    String? message,
    IconData? icon,
    bool isFullScreen = true,
  }) {
    return ErrorScreen(
      title: title ?? 'Nothing here yet',
      message: message ?? 'Content will appear here once available',
      icon: icon ?? Icons.inbox_rounded,
      isFullScreen: isFullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isFullScreen ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Icon Container with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.2),
                  AppTheme.surfaceContainer,
                ],
              ),
              border: Border.all(
                color: AppTheme.borderDark,
                width: 2,
              ),
            ),
            child: Icon(
              icon ?? (isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded),
              size: 56,
              color: isNetworkError ? AppTheme.textSecondary : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Title
          Text(
            title ?? 'Oops!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Message
          Text(
            message ?? 'Something went wrong',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Retry Button
          if (onRetry != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isFullScreen) {
      return Center(child: content);
    }
    return content;
  }
}

/// Helper function to determine if an error is a network error
bool isNetworkError(dynamic error) {
  final errorString = error.toString().toLowerCase();
  return errorString.contains('socketexception') ||
      errorString.contains('failed host lookup') ||
      errorString.contains('network') ||
      errorString.contains('connection') ||
      errorString.contains('timeout') ||
      errorString.contains('no internet');
}
