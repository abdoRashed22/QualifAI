// lib/features/accreditation/presentation/screens/accreditation_types_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

class AccreditationTypesScreen extends StatelessWidget {
  const AccreditationTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Ø§Ø®ØªØ± Ù†ÙˆØ¹ Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 24.h),
            _AccreditationTypeCard(
              icon: 'ðŸ›',
              title: 'Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯ Ø§Ù„Ø£ÙƒØ§Ø¯ÙŠÙ…ÙŠ',
              subtitle: 'Ø§Ø¹ØªÙ…Ø§Ø¯ Ù…Ø¤Ø³Ø³ÙŠ â€” Ø§Ù„Ù…Ø¹Ø§ÙŠÙŠØ± Ø§Ù„Ø´Ø§Ù…Ù„Ø© Ù„Ù„ÙƒÙ„ÙŠØ©',
              color: AppColors.navyBlue,
              onTap: () => context.push('${AppRoutes.standards}?type=1'),
            ),
            SizedBox(height: 16.h),
            _AccreditationTypeCard(
              icon: 'ðŸ“š',
              title: 'Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯ Ø§Ù„Ø¨Ø±Ø§Ù…Ø¬ÙŠ',
              subtitle: 'Ø§Ø¹ØªÙ…Ø§Ø¯ Ø§Ù„Ø¨Ø±Ù†Ø§Ù…Ø¬ / Ø§Ù„ØªØ®ØµØµ Ø§Ù„Ø£ÙƒØ§Ø¯ÙŠÙ…ÙŠ',
              color: AppColors.blue,
              onTap: () => context.push('${AppRoutes.standards}?type=2'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccreditationTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AccreditationTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Text('ØªÙ‚ÙŠÙŠÙ… Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12)),
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
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
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
