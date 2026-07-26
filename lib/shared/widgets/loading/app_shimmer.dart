// lib/shared/widgets/loading/app_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_radius.dart';

/// Replaces inline Shimmer loading patterns across the app
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? Theme.of(context).cardColor,
      highlightColor:
          highlightColor ?? Theme.of(context).cardColor.withOpacity(0.5),
      child: child,
    );
  }
}

/// A shimmer placeholder box
class AppShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.r8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3D5C) : const Color(0xFFE0E4EF),
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// A shimmer circle placeholder
class AppShimmerCircle extends StatelessWidget {
  final double size;

  const AppShimmerCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3D5C) : const Color(0xFFE0E4EF),
        shape: BoxShape.circle,
      ),
    );
  }
}
