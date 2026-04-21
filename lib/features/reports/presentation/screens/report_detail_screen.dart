// lib/features/reports/presentation/screens/report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/reports_cubit.dart';

class ReportDetailScreen extends StatelessWidget {
  final int reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..loadDetail(reportId),
      child: const _ReportDetailView(),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ØªÙ‚Ø±ÙŠØ±')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (ctx, state) {
          if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReportsError) return Center(child: Text(state.message));
          if (state is ReportDetailLoaded) {
            final r = state.report;
            final uploaded = (r['uploadedDocuments'] ?? 0) as int;
            final required = (r['requiredDocumentsCount'] ?? 1) as int;
            final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;
            final docs = (r['requiredDocuments'] as List?) ?? [];

            return ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              children: [
                // Completion card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Ø§Ù„Ø§Ø¹ØªÙ…Ø§Ø¯ Ø§Ù„Ø£ÙƒØ§Ø¯ÙŠÙ…ÙŠ  â€º  ${r['name'] ?? 'ØªÙ‚Ø±ÙŠØ±'}',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white60)),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).round()}%',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 32.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Ø¯Ø±Ø¬Ø© Ø§Ù„Ø§ÙƒØªÙ…Ø§Ù„',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: Colors.white60)),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(_pctColor(pct)),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Missing documents
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Ø§Ù„ÙØ¬ÙˆØ§Øª Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ© Ø§Ù„Ù…Ø·Ù„ÙˆØ¨Ø©', style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs.where((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        return doc['uploadedFile'] == null;
                      }).take(5).map((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  doc['name'] ?? 'Ù…Ø³ØªÙ†Ø¯ Ù…Ø·Ù„ÙˆØ¨',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.warning),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(Icons.warning_amber_outlined, size: 14.sp, color: AppColors.warning),
                            ],
                          ),
                        );
                      }),
                      if (docs.every((d) => (d as Map<String, dynamic>?)?['uploadedFile'] != null))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Ø¬Ù…ÙŠØ¹ Ø§Ù„Ù…Ø³ØªÙ†Ø¯Ø§Øª Ù…ÙƒØªÙ…Ù„Ø© âœ“',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.success)),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Documents list
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Ø§Ù„Ù…Ù„ÙØ§Øª (${docs.length})', style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs.take(10).map((d) {
                        final doc = d as Map<String, dynamic>? ?? {};
                        final hasFile = doc['uploadedFile'] != null;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                hasFile ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                                size: 16.sp,
                                color: hasFile ? AppColors.success : AppColors.error,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  doc['name'] ?? 'Ù…Ø³ØªÙ†Ø¯',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Ø±ÙØ¹ Ø§Ù„ØªÙ‚Ø±ÙŠØ± â†‘',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„ØªÙ‚Ø±ÙŠØ± Ù„Ù„Ù…Ø±Ø§Ø¬Ø¹ âœ“'), backgroundColor: AppColors.success),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: 'Ø§Ù„ØªÙˆØ§ØµÙ„ Ù…Ø¹ Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(AppRoutes.chatList),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'Ø§Ù„Ø¹ÙˆØ¯Ø© Ø¥Ù„Ù‰ Ø§Ù„Ù…Ù„ÙØ§Øª',
                  variant: AppButtonVariant.ghost,
                  onPressed: () { if (context.canPop()) context.pop(); else context.go(AppRoutes.reports); },
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color _pctColor(double pct) {
    if (pct >= 0.7) return AppColors.success;
    if (pct >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}
