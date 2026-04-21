// lib/features/reports/presentation/screens/reports_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/reports_cubit.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..loadReports(),
      child: const _ReportsListView(),
    );
  }
}

class _ReportsListView extends StatelessWidget {
  const _ReportsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ø§Ù„ØªÙ‚Ø§Ø±ÙŠØ±')),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (ctx, state) {
          if (state is ReportsLoading) return const Center(child: CircularProgressIndicator());
          if (state is ReportsError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: () => ctx.read<ReportsCubit>().loadReports(), child: const Text('Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©')),
            ]));
          }
          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ðŸ¤–', style: TextStyle(fontSize: 64.sp)),
                    SizedBox(height: 16.h),
                    const Text('Ù„Ù‚Ø¯ ØªÙ… Ø¥Ø±Ø³Ø§Ù„ ØªÙ‚Ø±ÙŠØ±Ùƒ Ø¨Ù†Ø¬Ø§Ø­\nÙˆØ³ÙˆÙ ØªØ¸Ù‡Ø± Ø¨Ù…Ø¬Ø±Ø¯ Ø§Ø³ØªÙ„Ø§Ù… Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹ Ù„Ù‡Ø§',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<ReportsCubit>().loadReports(),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: state.reports.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final r = state.reports[i] as Map<String, dynamic>? ?? {};
                  final uploaded = (r['uploadedDocuments'] ?? 0) as int;
                  final required = (r['requiredDocumentsCount'] ?? 1) as int;
                  final pct = required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;

                  return AppCard(
                    onTap: () => context.push(
                      AppRoutes.reportDetail.replaceFirst(':id', '${r['id'] ?? 0}'),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(color: AppColors.navyBlue, borderRadius: BorderRadius.circular(8.r)),
                              child: Text('Ø¹Ø±Ø¶ Ø§Ù„ØªÙ‚Ø±ÙŠØ±', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(r['name'] ?? 'ØªÙ‚Ø±ÙŠØ±', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${(pct * 100).round()}%',
                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, fontWeight: FontWeight.w700,
                                          color: pct >= 0.7 ? AppColors.success : pct >= 0.4 ? AppColors.warning : AppColors.error)),
                                  SizedBox(width: 8.w),
                                  Expanded(child: AppProgressBar(value: pct, height: 5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('ðŸ“‹', style: TextStyle(fontSize: 28.sp)),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
