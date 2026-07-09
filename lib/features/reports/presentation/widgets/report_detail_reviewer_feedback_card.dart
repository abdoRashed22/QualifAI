import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:qualif_ai/core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';

class ReportDetailReviewerFeedbackCard extends StatelessWidget {
  final String reviewerFeedback;

  const ReportDetailReviewerFeedbackCard({
    super.key,
    required this.reviewerFeedback,
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
                'ملاحظات المراجع',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.rate_review_outlined,
                color: AppColors.success,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            reviewerFeedback,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
