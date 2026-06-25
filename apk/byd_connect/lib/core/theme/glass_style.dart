import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Wrapper que aplica efeito glassmorphic blur em qualquer widget (ícones, textos, etc)
class GlassMorphicIcon extends StatelessWidget {
  final Widget child;
  final double size;
  final double blur;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showShadow;

  const GlassMorphicIcon({
    super.key,
    required this.child,
    this.size = 40,
    this.blur = 15,
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.glassBackground;
    final brdColor = borderColor ?? AppColors.glassBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: brdColor.withValues(alpha: 0.5),
              width: borderWidth,
            ),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Ícone individual com efeito glassmorphic
class GlassIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final double iconSize;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassIcon({
    super.key,
    required this.icon,
    this.size = 40,
    this.color,
    this.iconSize = 20,
    this.blur = 15,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphicIcon(
      size: size,
      blur: blur,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: Icon(
        icon,
        size: iconSize,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}

/// Ícone com estado ativo (highlighted)
class GlassIconActive extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color activeColor;
  final bool isActive;
  final double iconSize;
  final double blur;

  const GlassIconActive({
    super.key,
    required this.icon,
    required this.activeColor,
    this.size = 40,
    this.isActive = false,
    this.iconSize = 20,
    this.blur = 15,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphicIcon(
      size: size,
      blur: blur,
      backgroundColor: isActive
          ? activeColor.withValues(alpha: 0.3)
          : AppColors.glassBackground,
      borderColor: isActive ? activeColor : AppColors.glassBorder,
      showShadow: isActive,
      child: Icon(
        icon,
        size: iconSize,
        color: isActive ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}

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
