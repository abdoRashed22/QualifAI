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
import '../cubit/reports_state.dart';

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

            // اعرض نسبة الاكتمال بشكل مختلف عشان تبان أثناء التحميل/الواجهة
            // (مثال: من 0% إلى 83%).
            final pct = 0.83;

            final aiAnalysis = r.aiAnalysis;
            final reviewerFeedback = r.reviewerFeedback;
            // final requiredRevisions = r.requiredRevisions;

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
                        'الاعتماد الأكاديمي  ›  ${r.name}',
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
                      const SizedBox(
                        height: 0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'جاري عرض تحليل الذكاء الاصطناعي للتقرير...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.6),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'جاري عرض التعديلات المطلوبة للتقرير...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.6),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'جاري عرض ملاحظات المراجع للتقرير...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.6),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
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
