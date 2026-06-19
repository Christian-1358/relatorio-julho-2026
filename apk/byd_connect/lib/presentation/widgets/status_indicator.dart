import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final bool showLabel;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppColors.online : AppColors.offline,
            boxShadow: [
              BoxShadow(
                color: (isOnline ? AppColors.online : AppColors.offline)
                    .withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? AppColors.online : AppColors.offline,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
