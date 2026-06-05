// lib/features/reports/presentation/screens/report_detail_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(title: const Text("تقرير")),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (ctx, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportsError) {
            return Center(child: Text(state.message));
          }

          if (state is ReportDetailLoaded) {
            final r = state.report;

            final pct = (r['completionDegree'] is num
                    ? (r['completionDegree'] as num).toDouble()
                    : (r['completionPercentage'] is num
                        ? (r['completionPercentage'] as num).toDouble() / 100
                        : 0.0))
                .clamp(0.0, 1.0);

            final aiAnalysis =
                (r['aiAnalysis'] ?? 'لم يتم إتمام التحليل بعد').toString();
            final reviewerFeedback = (r['reviewerFeedback'] ??
                    r['reviewerAssessment'] ??
                    'لا توجد ملاحظات من المراجع حتى الآن')
                .toString();
            final requiredRevisions =
                (r['requiredRevisions'] ?? 'لا توجد تعديلات مطلوبة').toString();

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
                      Text(
                        'الاعتماد الأكاديمي  ›  ${r['name'] ?? 'تقرير'}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).round()}%',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('درجة الاكتمال',
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: Colors.white60)),
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

                // AI Analysis

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('تحليل الذكاء الاصطناعي',
                              style: Theme.of(context).textTheme.titleSmall),
                          SizedBox(width: 8.w),
                          Icon(Icons.smart_toy_outlined,
                              color: AppColors.blue, size: 20.sp),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        aiAnalysis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Required Revisions Section

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('التعديلات المطلوبة',
                              style: Theme.of(context).textTheme.titleSmall),
                          SizedBox(width: 8.w),
                          Icon(Icons.checklist_rtl_outlined,
                              color: AppColors.warning, size: 20.sp),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        requiredRevisions,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Reviewer Feedback Section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('ملاحظات المراجع',
                              style: Theme.of(context).textTheme.titleSmall),
                          SizedBox(width: 8.w),
                          Icon(Icons.rate_review_outlined,
                              color: AppColors.success, size: 20.sp),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        reviewerFeedback,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: "التواصل مع المراجع",
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(AppRoutes.chatList),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                AppButton(
                  label: 'العودة إلى القائمة',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.reports);
                    }
                  },
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
