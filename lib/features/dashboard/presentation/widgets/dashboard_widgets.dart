import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/app_card.dart';

import '../cubit/dashboard_cubit.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: AppCard(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class StandardRow extends StatelessWidget {
  final SectionSummary section;
  final Color color;

  const StandardRow({
    required this.section,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pct = section.completionPercent;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(section.name, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 6.h),
          AppProgressBar(value: pct),
        ],
      ),
    );
  }
}
