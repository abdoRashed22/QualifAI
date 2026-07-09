import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:qualif_ai/core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';

class ReportDetailRequiredRevisionsCard extends StatelessWidget {
  final String requiredRevisions;

  const ReportDetailRequiredRevisionsCard({
    super.key,
    required this.requiredRevisions,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'التعديلات المطلوبة',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.checklist_rtl_outlined,
                color: AppColors.warning,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            requiredRevisions,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
