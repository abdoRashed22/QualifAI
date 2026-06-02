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

            final uploaded = (r['uploadedDocuments'] ?? 0) as int;

            final required = (r['requiredDocumentsCount'] ?? 1) as int;

            final pct =
                required > 0 ? (uploaded / required).clamp(0.0, 1.0) : 0.0;

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

                // Missing documents

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الوثائق الرئيسية',
                          style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs
                          .where((d) {
                            final doc = d as Map<String, dynamic>? ?? {};

                            return !(doc['hasFile'] == true);
                          })
                          .take(5)
                          .map((d) {
                            final doc = d as Map<String, dynamic>? ?? {};

                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      doc['name'] ?? 'وثيقة مطلوبة',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12.sp,
                                          color: AppColors.warning),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(Icons.warning_amber_outlined,
                                      size: 14.sp, color: AppColors.warning),
                                ],
                              ),
                            );
                          }),
                      if (docs.every((d) =>
                          (d as Map<String, dynamic>?)?['hasFile'] == true))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'جميع المستندات مكتملة ✓',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: AppColors.success,
                              ),
                            ),
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
                      Text('الملفات (${docs.length})',
                          style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 12.h),
                      ...docs.map((d) {
                        final doc = d as Map<String, dynamic>? ?? {};

                        final hasFile = doc['hasFile'] == true;
                        final fileUrl = doc['fullFileUrl']?.toString() ?? '';
                        final fileName =
                            doc['name']?.toString() ?? 'وثيقة مطلوبة';

                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              if (hasFile) ...[
                                IconButton(
                                  icon: Icon(Icons.download_rounded,
                                      color: AppColors.navyBlue, size: 22.sp),
                                  onPressed: () async {
                                    if (fileUrl.isNotEmpty) {
                                      final uri = Uri.parse(fileUrl);
                                      try {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'لا يمكن تحميل الملف')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  tooltip: 'تحميل',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                SizedBox(width: 16.w),
                                IconButton(
                                  icon: Icon(Icons.visibility_rounded,
                                      color: AppColors.success, size: 22.sp),
                                  onPressed: () {
                                    if (fileUrl.isNotEmpty) {
                                      context.push(
                                        '${AppRoutes.fileViewer}?url=${Uri.encodeComponent(fileUrl)}&name=${Uri.encodeComponent(fileName)}',
                                      );
                                    }
                                  },
                                  tooltip: 'عرض الملف',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  child: Text(
                                    fileName,
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: hasFile
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5)),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Icon(
                                hasFile
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                size: 24.sp,
                                color: hasFile
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Notes Section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ملاحظات التقييم',
                          style: Theme.of(context).textTheme.titleSmall),
                      SizedBox(height: 8.h),
                      Text(
                        'يمكنك استخدام هذه المساحة لتدوين ملاحظاتك، وإرسالها للكلية أو المراجع.',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7)),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'أضف ملاحظاتك هنا...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
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
                        label: 'تقييم الاعتماد',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم حفظ تقييم الاعتماد')),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
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
