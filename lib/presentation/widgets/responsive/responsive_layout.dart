import 'package:flutter/material.dart';
import '../../../../core/utils/screen_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenUtils.tabletLimit) {
          return desktopBody ?? tabletBody ?? mobileBody;
        } else if (constraints.maxWidth >= ScreenUtils.mobileLimit) {
          return tabletBody ?? mobileBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
}
