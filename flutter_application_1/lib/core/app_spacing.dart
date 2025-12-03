import 'package:flutter/material.dart';

// App spacing constants
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Padding & Margin Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Common EdgeInsets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // Vertical Padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircle = 999.0;

  // Common BorderRadius
  static final BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);
  static final BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Avatar Sizes
  static const double avatarSM = 24.0;
  static const double avatarMD = 32.0;
  static const double avatarLG = 48.0;
  static const double avatarXL = 64.0;
}
