// lib/shared/widgets/states/app_no_results.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Replaces inline search no results states
class AppNoResults extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppNoResults({
    super.key,
    this.message = 'لا توجد نتائج للبحث',
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.all32(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: Theme.of(context).disabledColor,
            ),
            AppSpacing.h16(),
            Text(
              message,
              style: AppTypography.titleMedium(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
