// lib/features/admin/presentation/widgets/colleges/college_shimmer_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../shared/widgets/app_card.dart';

/// Shimmer loading card for colleges list
/// TODO: Replace inline shimmer code with this widget
class CollegeShimmerCard extends StatelessWidget {
  const CollegeShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
      child: AppCard(
        child: Row(
          children: [
            Container(
                width: 45.w,
                height: 25.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.r8.r))),
            AppSpacing.w12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: double.infinity,
                      height: 14.h,
                      color: Colors.white),
                  AppSpacing.h8(),
                  Container(width: 120.w, height: 10.h, color: Colors.white),
                ],
              ),
            ),
            AppSpacing.w12(),
            Container(
                width: 32.sp,
                height: 32.sp,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}
