// lib/shared/widgets/data_display/app_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_typography.dart';

/// Replaces inline progress bars across the app (colleges, reviewer, admin dashboard, standards)
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 100.0
  final double? height;
  final String? label;
  final bool showPercentage;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height,
    this.label,
    this.showPercentage = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  Color _defaultForeground() {
    if (foregroundColor != null) return foregroundColor!;
    if (value >= 70) return const Color(0xFF27AE60);
    if (value >= 40) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 100.0) / 100.0;
    final barHeight = height ?? 7.h;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        if (showPercentage) ...[
          Text(
            '${value.toInt()}%',
            style: AppTypography.caption(
              color: _defaultForeground(),
            )?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(barHeight),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: barHeight,
              backgroundColor: backgroundColor ??
                  (isDark ? const Color(0xFF2D3D5C) : const Color(0xFFE0E4EF)),
              valueColor: AlwaysStoppedAnimation<Color>(_defaultForeground()),
            ),
          ),
        ),
        if (label != null) ...[
          SizedBox(width: 8.w),
          Text(
            label!,
            style: AppTypography.caption()?.copyWith(fontFamily: 'Cairo'),
          ),
        ],
      ],
    );
  }
}
