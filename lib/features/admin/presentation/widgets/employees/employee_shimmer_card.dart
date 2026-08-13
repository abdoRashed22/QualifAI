// lib/features/admin/presentation/widgets/employees/employee_shimmer_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/loading/app_shimmer.dart';

class EmployeeShimmerCard extends StatelessWidget {
  const EmployeeShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AppCard(
        child: Row(
          children: [
            Column(
              children: [
                AppShimmerBox(width: 70, height: 25, radius: AppRadius.r8),
                AppSpacing.h6(),
                AppShimmerBox(width: 70, height: 25, radius: AppRadius.r8),
              ],
            ),
            AppSpacing.w12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppShimmerBox(width: double.infinity, height: 14),
                  AppSpacing.h8(),
                  AppShimmerBox(width: 120, height: 10),
                  AppSpacing.h8(),
                  AppShimmerBox(width: 60, height: 14, radius: AppRadius.r4),
                ],
              ),
            ),
            AppSpacing.w12(),
            const AppShimmerCircle(size: 44),
          ],
        ),
      ),
    );
  }
}
