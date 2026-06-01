import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../presentation/cubit/reviewer_cubit.dart';

class ReviewerSectionReviewScreen extends StatefulWidget {
  final int collegeId;
  final int sectionId;

  const ReviewerSectionReviewScreen({
    super.key,
    required this.collegeId,
    required this.sectionId,
  });

  @override
  State<ReviewerSectionReviewScreen> createState() =>
      _ReviewerSectionReviewScreenState();
}

class _ReviewerSectionReviewScreenState
    extends State<ReviewerSectionReviewScreen> {
  late final ReviewerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReviewerCubit>();
    _cubit.loadSectionFiles(widget.collegeId, widget.sectionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ReviewerCubit, ReviewerState>(
        builder: (context, state) {
          final appBarSectionName = state is ReviewerSectionLoaded
              ? _stringValue(
                  state.section['name'] ??
                      state.section['sectionName'] ??
                      state.section['standardName'] ??
                      state.section['title'] ??
                      state.section['sectionTitle'] ??
                      'المعيار',
                )
              : 'المعيار';

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(
                  AppRoutes.reviewerCollege.replaceFirst(
                    ':collegeId',
                    '${widget.collegeId}',
                  ),
                ),
              ),
              title: Text('مراجعة $appBarSectionName'),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReviewerState state) {
    if (state is ReviewerLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReviewerError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context
                  .read<ReviewerCubit>()
                  .loadSectionFiles(widget.collegeId, widget.sectionId),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is ReviewerSectionLoaded) {
      final section = state.section;
      final sectionName = _stringValue(
        section['name'] ??
            section['sectionName'] ??
            section['standardName'] ??
            section['title'] ??
            section['sectionTitle'] ??
            'معيار',
      );
      final sectionStatus = _sectionStatusLabel(section);
      // Calculate progress from pre-calculated percentage or compute from uploadedDocuments/totalDocuments
      double progress = _doubleValue(section['progressPercentage'] ??
          section['completionPercentage'] ??
          section['progress']);

      // If no pre-calculated percentage, compute from uploaded/total documents
      if (progress == 0 &&
          section['uploadedDocuments'] != null &&
          section['totalDocuments'] != null) {
        final uploaded = _intValue(section['uploadedDocuments']);
        final total = _intValue(section['totalDocuments']);
        if (total > 0) {
          progress = (uploaded / total) * 100.0;
        }
      }
      final aiEvaluation = _stringValue(section['aiEvaluation'] ??
          section['aiResult'] ??
          'تقييم AI غير متوفر لهذا المعيار');

      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(sectionName,
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 10.h),
                AppBadge(
                    label: sectionStatus, color: _statusColor(sectionStatus)),
                SizedBox(height: 14.h),
                Text('الملفات المرتبطة',
                    style: Theme.of(context).textTheme.titleMedium),
                if (progress > 0) ...[
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('نسبة الإكمال', style: TextStyle(fontSize: 13.sp)),
                      Text('${progress.round()}%',
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      minHeight: 8.h,
                      value: (progress / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation(_statusColor(sectionStatus)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('تقييم AI',
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 10.h),
                Text(aiEvaluation,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (state.files.isEmpty)
            AppCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    const Icon(Icons.file_present_outlined, size: 40),
                    SizedBox(height: 12.h),
                    const Text('لا توجد ملفات معروضة لهذا المعيار'),
                  ],
                ),
              ),
            )
          else
            ...state.files.map((file) {
              final title = _stringValue(file['name'] ??
                  file['fileName'] ??
                  file['documentName'] ??
                  'ملف');
              final status = _fileStatusLabel(file);
              final filePath = _stringValue(file['filePath'] ?? '');
              final hasFile = (file['submissionId'] != null &&
                  filePath.isNotEmpty &&
                  (file['originalName'] != null));

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                SizedBox(height: 6.h),
                                Text(
                                    _stringValue(file['description'] ??
                                        file['notes'] ??
                                        ''),
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12.sp)),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          AppBadge(label: status, color: _statusColor(status)),
                        ],
                      ),
                      if (hasFile) ...[
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final fileUrl =
                                  'https://qualefai.runasp.net${filePath}';
                              print('🔗 محاولة فتح الملف: $fileUrl');
                              try {
                                final uri = Uri.parse(fileUrl);
                                // Always try to launch, don't rely on canLaunchUrl
                                // as it may not work for all URLs
                                if (await launchUrl(uri,
                                    mode: LaunchMode.externalApplication)) {
                                  print('✅ تم فتح الملف بنجاح');
                                } else {
                                  print('❌ فشل في فتح الملف');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'لا يمكن فتح الملف. تحقق من الرابط'),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                print('⚠️ خطأ: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'خطأ في فتح الملف: ${e.toString()}'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('انقر لفتح الملف'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.h, horizontal: 12.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          SizedBox(height: 20.h),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('ملاحظات المراجعة'),
                SizedBox(height: 8.h),
                Text(
                  'يمكنك استخدام هذه المساحة لتدوين ملاحظاتك حول المعيار ومراجعته داخلياً.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 12.h),
                TextField(
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أضف ملاحظات المراجعة هنا...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'تقييم الاعتماد',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ تقييم الاعتماد'),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'التواصل مع الكلية',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.push(AppRoutes.chatList),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  double _doubleValue(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _sectionStatusLabel(dynamic section) {
    final raw = section is Map
        ? section['status'] ??
            section['sectionStatus'] ??
            section['reviewStatus']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('approve') || value.contains('موافق')) return 'معتمد';
    if (value.contains('reject') || value.contains('رفض')) return 'مرفوض';
    if (value.contains('revision') || value.contains('تعديل')) {
      return 'يحتاج تعديل';
    }
    return 'قيد المراجعة';
  }

  String _fileStatusLabel(dynamic file) {
    final raw = file is Map
        ? file['submissionStatus'] ??
            file['status'] ??
            file['fileStatus'] ??
            file['statusLabel']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('مكتمل') || value.contains('complete')) return 'مكتمل';
    if (value.contains('لم يُرفع') || value.contains('not upload'))
      return 'لم يُرفع';
    if (value.contains('بدون موعد') || value.contains('no deadline'))
      return 'بدون موعد';
    if (value.contains('approve') || value.contains('موافق')) return 'معتمد';
    if (value.contains('reject') || value.contains('رفض')) return 'مرفوض';
    if (value.contains('revision') || value.contains('تعديل')) {
      return 'يحتاج تعديل';
    }
    if (value.contains('pending') || value.contains('قيد')) {
      return 'قيد المراجعة';
    }
    return 'غير معروف';
  }

  Color _statusColor(String status) {
    if (status == 'معتمد' || status == 'مكتمل') return Colors.green;
    if (status == 'مرفوض') return Colors.red;
    if (status == 'يحتاج تعديل') return Colors.orange;
    if (status == 'قيد المراجعة') return Colors.blue;
    if (status == 'لم يُرفع') return Colors.grey;
    if (status == 'بدون موعد') return Colors.amber;
    return Colors.grey;
  }
}
