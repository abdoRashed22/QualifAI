import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

Widget buildBulletPoint(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
            child: Text(text,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo'))),
        SizedBox(width: 8.w),
        Icon(Icons.check_circle, color: AppColors.success, size: 16.sp),
      ],
    ),
  );
}

Widget buildLegend(String title, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo')),
      SizedBox(width: 6.w),
      Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    ],
  );
}

Widget buildProgressBar(
    BuildContext context, String title, int count, int total, Color color) {
  final pct = total > 0 ? (count / total) : 0.0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${(pct * 100).round()}%',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  fontSize: 13.sp)),
          Text(title, style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo')),
        ],
      ),
      SizedBox(height: 6.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: LinearProgressIndicator(
          value: pct,
          backgroundColor: Theme.of(context).dividerColor,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8.h,
        ),
      ),
    ],
  );
}
