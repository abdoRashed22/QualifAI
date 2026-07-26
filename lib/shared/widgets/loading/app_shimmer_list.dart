// lib/shared/widgets/loading/app_shimmer_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/app_card.dart';

/// Replaces inline shimmer list patterns across the app
class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const AppShimmerList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: padding ?? AppSpacing.listPadding(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => AppSpacing.h10(),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
        child: AppCard(
          child: SizedBox(
            height: itemHeight.h,
            child: Row(
              children: [
                Container(
                  width: 45.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2D3D5C)
                        : const Color(0xFFE0E4EF),
                    borderRadius: BorderRadius.circular(AppRadius.r8.r),
                  ),
                ),
                AppSpacing.w12(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14.h,
                        color: isDark
                            ? const Color(0xFF2D3D5C)
                            : const Color(0xFFE0E4EF),
                      ),
                      AppSpacing.h8(),
                      Container(
                        width: 120.w,
                        height: 10.h,
                        color: isDark
                            ? const Color(0xFF2D3D5C)
                            : const Color(0xFFE0E4EF),
                      ),
                    ],
                  ),
                ),
                AppSpacing.w12(),
                Container(
                  width: 32.sp,
                  height: 32.sp,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2D3D5C)
                        : const Color(0xFFE0E4EF),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
