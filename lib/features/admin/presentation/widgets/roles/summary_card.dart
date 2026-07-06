import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: color)),
          SizedBox(height: 4.h),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
