import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - premium dark theme
  static const Color primary = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFF2D2D2D);
  static const Color primaryDark = Color(0xFF0D0D0D);

  // Background colors - clean light theme (iOS style)
  static const Color background = Color(0xFFF0F0F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFE8E8EC);
  static const Color cardBg = Color(0xFFF5F5F7);

  // Accent colors
  static const Color accent = Color(0xFF1A1A1A);
  static const Color accentGreen = Color(0xFF27AE60);
  static const Color petroleumBlue = Color(0xFF1A3A5C);

  // Status colors
  static const Color online = Color(0xFF27AE60);
  static const Color offline = Color(0xFF8E8E93);
  static const Color locked = Color(0xFFE74C3C);
  static const Color unlocked = Color(0xFF27AE60);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFFAEAEB2);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Dark theme text (for dark backgrounds)
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFAEAEB2);

  // Card colors
  static const Color cardBorder = Color(0xFFE5E5EA);
  static const Color cardShadow = Color(0x0A000000);

  // Glass effect colors
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0xFFD0D5DD);
  static const Color glassShadow = Color(0x20000000);

  // Glass icon colors
  static const Color glassIconBackground = Color(0x40FFFFFF);
  static const Color glassIconBorder = Color(0x80FFFFFF);
  static const Color glassIconActiveBg = Color(0xFF1A1A1A);
  static const Color glassIconActiveBorder = Color(0xFF1A1A1A);

  // Frosted glass overlay
  static Color get frostedGlass => Colors.white.withValues(alpha: 0.25);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF3D3D3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient batteryGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFFF39C12), Color(0xFFE74C3C)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xF0FFFFFF),
      Color(0xE0FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
