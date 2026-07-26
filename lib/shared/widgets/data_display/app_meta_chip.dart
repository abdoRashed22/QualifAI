// lib/shared/widgets/data_display/app_meta_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Replaces: MetaChip (reviewer), InfoChip (admin/roles), _buildMetaChip (colleges)
class AppMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? borderRadius;
  final double backgroundOpacity;
  final bool showBorder;
  final double borderOpacity;
  final VoidCallback? onTap;

  const AppMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.borderRadius,
    this.backgroundOpacity = 0.1,
    this.showBorder = false,
    this.borderOpacity = 0.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withOpacity(backgroundOpacity),
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.r20.r),
          border: showBorder
              ? Border.all(color: color.withOpacity(borderOpacity))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            AppSpacing.w4(),
            Text(
              label,
              style: AppTypography.caption(color: color)?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
