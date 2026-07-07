import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class SupportHeader extends StatelessWidget {
  const SupportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.support_agent, size: 80.sp, color: AppColors.navyBlue),
        SizedBox(height: 16.h),
        Text(
          'فريق الدعم',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'نحن نقدم دعمًا موثوقًا وحلولًا مخصصة لضمان حل مشكلاتك بسرعة وكفاءة.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
