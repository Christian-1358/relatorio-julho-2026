import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final double size;
  final Color? activeColor;
  final bool showLabel;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.size = 56,
    this.activeColor,
    this.showLabel = true,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glass container with iPhone-style effect
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isActive
                          ? [
                              activeColor.withValues(alpha: _isPressed ? 0.5 : 0.4),
                              activeColor.withValues(alpha: _isPressed ? 0.3 : 0.2),
                            ]
                          : [
                              AppColors.glassBackground,
                              AppColors.glassBackground.withValues(alpha: 0.5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.isActive
                          ? activeColor.withValues(alpha: 0.8)
                          : AppColors.glassBorder,
                      width: widget.isActive ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                      if (widget.isActive)
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.isActive)
                        Container(
                          width: widget.size * 0.7,
                          height: widget.size * 0.7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                activeColor.withValues(alpha: 0.3),
                                activeColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      Icon(
                        widget.icon,
                        color: widget.isActive
                            ? Colors.white
                            : AppColors.textPrimary,
                        size: widget.size * 0.45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: widget.size + 10,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isActive ? activeColor : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
