// lib/shared/widgets/data_display/app_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Replaces inline CircleAvatar patterns with fallback to first letter
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
  });

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey.shade200;
    final txtColor = textColor ?? Colors.grey.shade600;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r12.r),
        child: Image.network(
          imageUrl!,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(bgColor, txtColor),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size.w,
              height: size.w,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.r12.r),
              ),
              child: Center(
                child: SizedBox(
                  width: size.w * 0.4,
                  height: size.w * 0.4,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildFallback(bgColor, txtColor);
  }

  Widget _buildFallback(Color bgColor, Color txtColor) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.r12.r),
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTypography.bodyMedium(color: txtColor)?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: (size * 0.35).sp,
          ),
        ),
      ),
    );
  }
}
