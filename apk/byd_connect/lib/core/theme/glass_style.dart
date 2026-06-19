import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassStyle {
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      gradient: AppColors.glassGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadow,
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration glassDecorationWithRadius(double radius) {
    return BoxDecoration(
      gradient: AppColors.glassGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadow,
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration get iconGlassDecoration {
    return BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
    );
  }

  static BoxDecoration get buttonGlassDecoration {
    return BoxDecoration(
      gradient: AppColors.glassGradient,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
    );
  }

  static BoxDecoration iconSquareDecoration(bool isActive) {
    return BoxDecoration(
      color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.glassBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isActive ? AppColors.primary : AppColors.glassBorder,
        width: 1.5,
      ),
    );
  }
}
