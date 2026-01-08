import 'package:flutter/material.dart';

/// Responsive breakpoints as per PRD specification.
class Breakpoints {
  Breakpoints._();

  /// Mobile: < 480px
  static const double mobile = 480;

  /// Tablet: 480px - 1024px
  static const double tablet = 1024;

  /// Desktop: > 1024px (same value, condition is >= 1024)
  static const double desktop = 1024;

  /// Maximum content width for desktop layouts.
  static const double maxContentWidth = 1440;
}

/// Extension on [BuildContext] for responsive design utilities.
///
/// Provides easy access to device type checks, responsive grid columns,
/// and adaptive layout properties based on screen width.
extension ResponsiveContext on BuildContext {
  /// Get the current screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get the current screen height.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns `true` if the screen width is less than the mobile breakpoint (480px).
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Returns `true` if the screen width is between mobile and tablet breakpoints (480px - 1024px).
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Returns `true` if the screen width is greater than or equal to the desktop breakpoint (1024px).
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// Returns the number of grid columns based on the current screen size.
  ///
  /// - Mobile: 2 columns
  /// - Tablet: 4 columns
  /// - Desktop: 6 columns
  int get gridColumns {
    if (isDesktop) return 6;
    if (isTablet) return 4;
    return 2;
  }

  /// Returns the child aspect ratio for grid items based on screen size.
  double get gridAspectRatio => isMobile ? 0.65 : 0.7;

  /// Returns the appropriate screen padding for the current device type.
  EdgeInsets get screenPadding {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 48);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  /// Returns the maximum content width, useful for centering content on desktop.
  double get maxContentWidth =>
      isDesktop ? Breakpoints.maxContentWidth : double.infinity;

  // --- Navigation Type ---

  /// Returns `true` if the app should use a side drawer for navigation (desktop).
  bool get useDrawer => isDesktop;

  /// Returns `true` if the app should use bottom navigation (mobile/tablet).
  bool get useBottomNav => !isDesktop;

  // --- Spacing ---

  /// Returns appropriate spacing value based on screen size.
  double get responsiveSpacing {
    if (isDesktop) return 24;
    if (isTablet) return 16;
    return 12;
  }
}
