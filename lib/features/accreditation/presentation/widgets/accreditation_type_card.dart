import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccreditationTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const AccreditationTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Text('عرض المعايير',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 12)),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(width: 10.w),
                      Text(icon, style: TextStyle(fontSize: 32.sp)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
