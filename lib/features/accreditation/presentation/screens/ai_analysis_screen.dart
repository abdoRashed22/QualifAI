// lib/features/accreditation/presentation/screens/ai_analysis_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/accreditation_cubit.dart';

class AiAnalysisScreen extends StatefulWidget {
  final int documentId;
  const AiAnalysisScreen({super.key, required this.documentId});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  Future<void> _pickAndUploadAnotherFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    if (!context.mounted) return;
    context.read<AccreditationCubit>().uploadDocument(widget.documentId, file);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccreditationCubit>()..getAnalysis(widget.documentId),
      child: BlocConsumer<AccreditationCubit, AccreditationState>(
        listener: (context, state) {
          if (state is DocumentUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم رفع الملف وإعادة التحليل بنجاح ✅'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<AccreditationCubit>().getAnalysis(widget.documentId);
          }
          if (state is AccreditationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final analysis =
              state is AnalysisLoaded ? state.analysis : <String, dynamic>{};
          final score =
              ((analysis['score'] as num?)?.toDouble() ?? 72).clamp(0, 100);
          final quality = (analysis['quality'] ?? 'عالية').toString();
          final documentType = (analysis['documentType'] ?? 'تقرير').toString();
          final language = (analysis['language'] ?? 'عربية').toString();
          final ocrScore = (analysis['ocrScore'] ?? '94%').toString();
          final status = (analysis['status'] ?? 'مكتمل').toString();
          final deadline = (analysis['deadline'] ?? 'غير محدد').toString();
          final deadlineStatus = (analysis['deadlineStatus'] ?? 'ضمن المدة')
              .toString();
          final recommendations = (analysis['recommendations'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[
                'يفتقر التقرير إلى توصيف واضح للأهداف الاستراتيجية',
                'لم يتم ذكر آليات المتابعة والتقييم بشكل كافٍ',
                'التنسيق العام جيد والمحتوى منظم بشكل واضح',
              ];

          final isBusy =
              state is AccreditationLoading || state is UploadingDocument;

          return Scaffold(
            appBar: AppBar(title: const Text('نتائج التحليل الذكي')),
            body: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'نتيجة التحليل',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
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
                                value: score / 100,
                                strokeWidth: 10.w,
                                backgroundColor: Theme.of(context).dividerColor,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.success,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${score.round()}',
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
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'جودة المستند',
                        value: quality,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MetricCard(
                        label: 'نوع المستند',
                        value: documentType,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'اللغة',
                        value: language,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _MetricCard(
                        label: 'درجة OCR',
                        value: ocrScore,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppCard(
                  child: Column(
                    children: [
                      _MetaRow(label: 'حالة المستند', value: status),
                      SizedBox(height: 8.h),
                      _MetaRow(label: 'الموعد النهائي', value: deadline),
                      SizedBox(height: 8.h),
                      _MetaRow(
                        label: 'حالة الموعد النهائي',
                        value: deadlineStatus,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'التوصيات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 12.h),
                ...recommendations.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _RecommendationTile(
                      icon: Icons.analytics_outlined,
                      text: item,
                      color: AppColors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.reports),
                        child: const Text("عرض التصنيفات"),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () => _pickAndUploadAnotherFile(context),
                        child: const Text("تحليل ملف آخر"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.navyBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

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
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
  const _RecommendationTile({
    required this.icon,
    required this.text,
    required this.color,
  });

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
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: color,
              ),
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

