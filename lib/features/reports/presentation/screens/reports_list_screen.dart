// lib/features/reports/presentation/screens/reports_list_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/cache/hive_cache.dart';

import '../../../../core/permissions/permission_manager.dart';

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
    final pm = PermissionManager(sl<HiveCache>());

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      // API: POST /api/Reports/upload -> Quality Manager ONLY
      floatingActionButton: pm.isManager
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  if (context.mounted) {
                    context.read<ReportsCubit>().uploadReport(file);
                  }
                }
              },
              label: const Text('رفع تقرير'),
              icon: const Icon(Icons.upload_file),
            )
          : null,
      body: BlocConsumer<ReportsCubit, ReportsState>(
        listener: (ctx, state) {
          if (state is ReportActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is ReportDownloadSuccess) {
            if (state.url.startsWith('http')) {
              launchUrl(Uri.parse(state.url),
                  mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text(state.url), backgroundColor: AppColors.blue),
              );
            }
          }
        },
        builder: (ctx, state) {
          if (state is ReportsLoading) {
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: double.infinity,
                                height: 14.h,
                                color: Colors.white),
                            SizedBox(height: 8.h),
                            Container(
                                width: 80.w, height: 10.h, color: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 28.sp,
                        height: 28.sp,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state is ReportsError) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(
                  onPressed: () => ctx.read<ReportsCubit>().loadReports(),
                  child: const Text('إعادة المحاولة')),
            ]));
          }

          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 64.sp)),
                    SizedBox(height: 16.h),
                    const Text(
                        "لقد تم إرسال تقريرك بنجاح وسوف تظهر بمجرد استلام المراجع لها",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.navyBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await ctx.read<ReportsCubit>().loadReports();
              },
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                itemCount: state.reports.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final r = state.reports[i] as Map<String, dynamic>? ?? {};

                  final uploaded = (r['uploadedDocuments'] ?? 0) as int;

                  final required = (r['requiredDocumentsCount'] ?? 1) as int;

                  final collegeName = (r['collegeName'] ?? '').toString();
                  final collegeId =
                      int.tryParse(r['collegeId']?.toString() ?? '0') ?? 0;

                  final pct = required > 0
                      ? (uploaded / required).clamp(0.0, 1.0)
                      : 0.0;
                  final status = (r['status'] ?? 'قيد المراجعة').toString();

                  return AppCard(
                    onTap: () => context.push(
                      AppRoutes.reportDetail
                          .replaceFirst(':id', '${r['id'] ?? 0}'),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push(
                                  AppRoutes.reportDetail
                                      .replaceFirst(':id', '${r['id'] ?? 0}'),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                    color: AppColors.navyBlue,
                                    borderRadius: BorderRadius.circular(8.r)),
                                child: Text("تفاصيل التقرير",
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        color: Colors.white)),
                              ),
                            ),
                            if (pm.isEmployee) ...[
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () => ctx
                                    .read<ReportsCubit>()
                                    .downloadCollegeReport(collegeId),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(8.r)),
                                  child: Text("تحميل التقرير",
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11.sp,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (pm.isEmployee && collegeName.isNotEmpty)
                                Text(collegeName,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        color: AppColors.blue),
                                    textAlign: TextAlign.right),
                              Text(r['name'] ?? "تقرير",
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textAlign: TextAlign.right),
                              SizedBox(height: 4.h),
                              Text('الحالة: $status',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.right),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${(pct * 100).round()}%',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: pct >= 0.7
                                              ? AppColors.success
                                              : pct >= 0.4
                                                  ? AppColors.warning
                                                  : AppColors.error)),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                      child: AppProgressBar(
                                          value: pct, height: 5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(' 📋', style: TextStyle(fontSize: 28.sp)),
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
