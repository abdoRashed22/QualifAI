// lib/features/admin/presentation/widgets/roles/summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_card.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: color),
          AppSpacing.h8(),
          Text(
            value,
            style: AppTypography.headlineSmall()?.copyWith(color: color),
          ),
          AppSpacing.h4(),
          Text(
            title,
            style: AppTypography.caption(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
