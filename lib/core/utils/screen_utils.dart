import 'package:flutter/material.dart';

class ScreenUtils {
  // Breakpoints
  static const double mobileLimit = 600.0;
  static const double tabletLimit = 1100.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileLimit;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileLimit &&
      MediaQuery.of(context).size.width < tabletLimit;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletLimit;
}
