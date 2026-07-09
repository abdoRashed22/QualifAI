import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:qualif_ai/core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';

class ReportDetailAiCard extends StatelessWidget {
  final String aiAnalysis;

  const ReportDetailAiCard({super.key, required this.aiAnalysis});

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
                'تحليل الذكاء الاصطناعي',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.smart_toy_outlined,
                color: AppColors.blue,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            aiAnalysis,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
