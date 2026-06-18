import 'package:flutter/material.dart';

/// Breakpoint helpers — mandated by the AYA design system.
class Responsive {
  Responsive._();

  static bool isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 900;
  static bool isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 900;

  static double padding(BuildContext ctx) {
    if (isMobile(ctx)) return 16.0;
    if (isTablet(ctx)) return 24.0;
    return 32.0;
  }

  static int gridColumns(BuildContext ctx) {
    if (isMobile(ctx)) return 2;
    if (isTablet(ctx)) return 3;
    return 4;
  }
}
