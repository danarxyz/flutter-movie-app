import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SnackBarUtils {
  // Default duration for all snackbars
  static const Duration _defaultDuration = Duration(seconds: 2);

  static void showSuccess(BuildContext context, String message) {
    _show(
      context, 
      message, 
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context, 
      message, 
      backgroundColor: Colors.red.shade700, // or AppTheme.error
      icon: Icons.error_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context, 
      message, 
      backgroundColor: AppTheme.surfaceContainer,
      icon: Icons.info_outline,
    );
  }

  // Specialized for Watchlist actions (with undo)
  static void showWithAction(
    BuildContext context, 
    String message, {
    required String actionLabel,
    required VoidCallback onPressed,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Prevent stacking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
             // Optional: Add icon if needed, or keep simple for actions
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.surfaceContainer,
        behavior: SnackBarBehavior.floating,
        duration: _defaultDuration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5), width: 1),
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: AppTheme.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide immediately on click
            onPressed();
          },
        ),
      ),
    );
  }

  static void _show(
    BuildContext context, 
    String message, {
    required Color backgroundColor, 
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Prevent stacking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: _defaultDuration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
