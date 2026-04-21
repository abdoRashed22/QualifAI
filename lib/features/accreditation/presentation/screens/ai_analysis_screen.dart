// lib/features/accreditation/presentation/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class AiAnalysisScreen extends StatelessWidget {
  final int documentId;
  const AiAnalysisScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    // The AI analysis results come embedded in the uploadDocument response
    // or from the section detail. We display what was returned.
    return Scaffold(
      appBar: AppBar(title: const Text('Ù†ØªØ§Ø¦Ø¬ Ø§Ù„ØªØ­Ù„ÙŠÙ„ Ø§Ù„Ø°ÙƒÙŠ')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
        children: [
          // Score circle
          Center(
            child: Column(
              children: [
                Text('Ù†ØªÙŠØ¬Ø© Ø§Ù„ØªØ­Ù„ÙŠÙ„', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).disabledColor)),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140.w,
                        height: 140.w,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 10.w,
                          backgroundColor: Theme.of(context).dividerColor,
                          valueColor: const AlwaysStoppedAnimation(AppColors.success),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '72',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Metrics grid
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Ø¬ÙˆØ¯Ø© Ø§Ù„Ù…Ø³ØªÙ†Ø¯', value: 'Ø¹Ø§Ù„ÙŠØ©', color: AppColors.success)),
              SizedBox(width: 10.w),
              Expanded(child: _MetricCard(label: 'Ù†ÙˆØ¹ Ø§Ù„Ù…Ø³ØªÙ†Ø¯', value: 'ØªÙ‚Ø±ÙŠØ±', color: AppColors.blue)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _MetricCard(label: 'Ø§Ù„Ù„ØºØ©', value: 'Ø¹Ø±Ø¨ÙŠ', color: AppColors.navyBlue)),
              SizedBox(width: 10.w),
              Expanded(child: _MetricCard(label: 'Ø¯Ù‚Ø© OCR', value: '94%', color: AppColors.success)),
            ],
          ),
          SizedBox(height: 24.h),

          // Recommendations
          Text('Ø§Ù„ØªÙˆØµÙŠØ§Øª', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 12.h),
          _RecommendationTile(
            icon: Icons.warning_amber_outlined,
            text: 'ÙŠÙØªÙ‚Ø± Ø§Ù„ØªÙ‚Ø±ÙŠØ± Ø¥Ù„Ù‰ ØªÙˆØµÙŠÙ ÙˆØ§Ø¶Ø­ Ù„Ù„Ø£Ù‡Ø¯Ø§Ù Ø§Ù„Ø§Ø³ØªØ±Ø§ØªÙŠØ¬ÙŠØ©',
            color: AppColors.warning,
          ),
          SizedBox(height: 8.h),
          _RecommendationTile(
            icon: Icons.cancel_outlined,
            text: 'Ù„Ù… ÙŠØªÙ… Ø°ÙƒØ± Ø¢Ù„ÙŠØ§Øª Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø© ÙˆØ§Ù„ØªÙ‚ÙŠÙŠÙ… Ø¨Ø´ÙƒÙ„ ÙƒØ§ÙÙ',
            color: AppColors.error,
          ),
          SizedBox(height: 8.h),
          _RecommendationTile(
            icon: Icons.check_circle_outline,
            text: 'Ø§Ù„ØªÙ†Ø³ÙŠÙ‚ Ø§Ù„Ø¹Ø§Ù… Ø¬ÙŠØ¯ ÙˆØ§Ù„Ù…Ø­ØªÙˆÙ‰ Ù…Ù†Ø¸Ù… Ø¨Ø´ÙƒÙ„ ÙˆØ§Ø¶Ø­',
            color: AppColors.success,
          ),
          SizedBox(height: 24.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Ø¹Ø±Ø¶ Ø§Ù„ØªØµÙ†ÙŠÙØ§Øª'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('ØªØ­Ù„ÙŠÙ„ Ù…Ù„Ù Ø¢Ø®Ø±'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 15.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _RecommendationTile({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: color),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 10.w),
          Icon(icon, color: color, size: 20.sp),
        ],
      ),
    );
  }
}
