import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
    fontWeight: FontWeight.w500,
  );

  static final BorderRadius radiusSmall = BorderRadius.circular(8);
  static final BorderRadius radiusMedium = BorderRadius.circular(14);
  static final BorderRadius radiusLarge = BorderRadius.circular(20);
  static final BorderRadius radiusPill = BorderRadius.circular(999);
}
