import 'package:flutter/material.dart';

abstract class AppColors {
  static Color transparentWhite = const Color(
    0xFFFFFFFF,
  ).withValues(alpha: 0.8);

  static Color positiveGreen = const Color(0xFF43A047);

  static Color negativeRed = const Color(0xFFE53935);

  static Color disabledGray = const Color(0xFF9E9E9E);

  static Color textGray = const Color(0xFF616161);

  static Color primaryGray = const Color(0xFFF5F5F5);

  static Color errorText = const Color(0xFFFB8C00);

  static Color primaryTransparentOrange = const Color(
    0xFFEF6C00,
  ).withValues(alpha: 0.8);
}
