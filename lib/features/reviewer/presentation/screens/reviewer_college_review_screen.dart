import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../presentation/cubit/reviewer_cubit.dart';

class ReviewerCollegeReviewScreen extends StatefulWidget {
  final int collegeId;

  const ReviewerCollegeReviewScreen({
    super.key,
    required this.collegeId,
  });

  @override
  State<ReviewerCollegeReviewScreen> createState() =>
      _ReviewerCollegeReviewScreenState();
}

class _ReviewerCollegeReviewScreenState
    extends State<ReviewerCollegeReviewScreen> {
  late final ReviewerCubit _cubit;
  final TextEditingController _notesController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReviewerCubit>();
    _cubit.loadCollege(widget.collegeId);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراجعة الكلية'),
        ),
        body: BlocConsumer<ReviewerCubit, ReviewerState>(
          listener: (context, state) {
            if (state is ReviewerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.pop();
            }
            if (state is ReviewerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
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
                          .loadCollege(widget.collegeId),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is ReviewerCollegeLoaded) {
              final college = state.college;
              final name = _stringValue(college['name'] ??
                  college['collegeName'] ??
                  college['title']);
              final type = _stringValue(
                  college['accreditationType'] ?? college['type'] ?? '');
              final university = _stringValue(college['university']);
              final readiness = _doubleValue(college['readinessPercentage'] ??
                  college['readinessPct'] ??
                  college['completionPercentage']);
              final progressStatus = _stringValue(college['progressStatus']);
              final accreditationStatus = _stringValue(
                  college['accreditationStatus'] ?? college['status']);
              final progressStatusColor = _colorFromValue(
                  college['progressStatusColor'], Colors.orange);
              final accreditationStatusColor = _colorFromValue(
                  college['accreditationStatusColor'], Colors.blueGrey);
              final lastUploadDate = _formatDate(college['lastUploadDate']);
              final decisionDate =
                  _formatDate(college['accreditationDecisionDate']);
              final rejectionReason = _stringValue(college['rejectionReason']);
              final sections = state.sections;
              return ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(name,
                            style: Theme.of(context).textTheme.titleLarge),
                        if (university.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(university,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500)),
                        ],
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          alignment: WrapAlignment.end,
                          children: [
                            AppBadge(
                                label: type.isNotEmpty
                                    ? 'نوع الاعتماد: $type'
                                    : 'نوع غير محدد',
                                color: Colors.blueGrey),
                            if (progressStatus.isNotEmpty)
                              AppBadge(
                                label: progressStatus,
                                color: progressStatusColor,
                              ),
                            if (accreditationStatus.isNotEmpty)
                              AppBadge(
                                label: accreditationStatus,
                                color: accreditationStatusColor,
                              ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        if (readiness > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('نسبة الجاهزية',
                                  style: TextStyle(fontSize: 14.sp)),
                              Text('${readiness.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          LinearProgressIndicator(
                            value: (readiness / 100).clamp(0.0, 1.0),
                            minHeight: 8.h,
                            color: Colors.green,
                            backgroundColor: const Color(0x3327AE60),
                          ),
                          SizedBox(height: 14.h),
                        ],
                        Row(
                          children: [
                            _metricTile('عدد المعايير', '${sections.length}'),
                            SizedBox(width: 10.w),
                            _metricTile(
                                'المراجعات', '${_completedCount(sections)}'),
                          ],
                        ),
                        if (lastUploadDate.isNotEmpty ||
                            decisionDate.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (lastUploadDate.isNotEmpty)
                                  Text('آخر رفع: $lastUploadDate',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[700])),
                                if (decisionDate.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 6.h),
                                    child: Text('تاريخ القرار: $decisionDate',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[700])),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (rejectionReason.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('سبب الرفض'),
                          SizedBox(height: 8.h),
                          Text(rejectionReason,
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.grey[800])),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  Text('المعايير المخصصة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12.h),
                  if (sections.isEmpty)
                    AppCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined, size: 40),
                            SizedBox(height: 12.h),
                            const Text('لا توجد معايير للعرض'),
                          ],
                        ),
                      ),
                    )
                  else
                    ...sections.map((section) {
                      final sectionId =
                          _intValue(section['id'] ?? section['sectionId']);
                      final sectionName = _stringValue(
                          section['name'] ?? section['title'] ?? 'معيار');
                      final sectionStatus = _sectionStatusLabel(section);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          onTap: () => context.go(AppRoutes.reviewerSection
                              .replaceAll(':collegeId', '${widget.collegeId}')
                              .replaceAll(':sectionId', '$sectionId')),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(sectionName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  AppBadge(
                                      label: sectionStatus,
                                      color: _statusColor(sectionStatus)),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'انقر لعرض الملفات والتعليقات',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12.sp),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  AppButton(
                                    label: 'عرض الملفات',
                                    variant: AppButtonVariant.outline,
                                    fullWidth: false,
                                    height: 38.h,
                                    onPressed: () => context.go(AppRoutes
                                        .reviewerSection
                                        .replaceAll(
                                            ':collegeId', '${widget.collegeId}')
                                        .replaceAll(
                                            ':sectionId', '$sectionId')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  SizedBox(height: 18.h),
                  AppButton(
                    label: 'عرض التقارير',
                    onPressed: () => context.go(AppRoutes.reports),
                  ),
                  SizedBox(height: 18.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('قرار الاعتماد', textAlign: TextAlign.right),
                        SizedBox(height: 12.h),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          items: _statusOptions.entries
                              .map(
                                (option) => DropdownMenuItem(
                                    value: option.key,
                                    child: Text(option.value)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: 'ملاحظات المراجع',
                          controller: _notesController,
                          maxLines: 4,
                        ),
                        SizedBox(height: 16.h),
                        AppButton(
                          label: 'إرسال القرار',
                          onPressed: () =>
                              context.read<ReviewerCubit>().submitDecision(
                                    widget.collegeId,
                                    _selectedStatus,
                                    _notesController.text,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  int _completedCount(List<dynamic> sections) {
    return sections.where((section) {
      final status = _sectionStatusLabel(section);
      return status == 'معتمد' || status == 'مرفوض';
    }).length;
  }

  Map<String, String> get _statusOptions => {
        'approved': 'موافق',
        'rejected': 'مرفوض',
        'pending': 'قيد المراجعة',
        'needs revision': 'يحتاج تعديل',
      };

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  double _doubleValue(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  Color _colorFromValue(dynamic rawValue, Color fallback) {
    final value = rawValue?.toString().trim();
    if (value == null || value.isEmpty) return fallback;

    final hex = value.replaceAll('#', '');
    if (RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(hex)) {
      return Color(int.parse(hex, radix: 16));
    }

    switch (value.toLowerCase()) {
      case 'red':
      case 'danger':
        return Colors.red;
      case 'orange':
      case 'warning':
        return Colors.orange;
      case 'green':
      case 'success':
        return Colors.green;
      case 'blue':
      case 'info':
        return Colors.blue;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow;
      default:
        return fallback;
    }
  }

  String _sectionStatusLabel(dynamic section) {
    final raw = section is Map
        ? section['status'] ??
            section['sectionStatus'] ??
            section['reviewStatus']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('approve') || value.contains('موافق')) return 'معتمد';
    if (value.contains('reject') || value.contains('رفض')) {
      return 'مرفوض';
    }
    if (value.contains('revision') || value.contains('تعديل')) {
      return 'يحتاج تعديل';
    }
    return 'قيد المراجعة';
  }

  Widget _metricTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text(label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'معتمد') return Colors.green;
    if (status == 'مرفوض') return Colors.red;
    if (status == 'يحتاج تعديل') return Colors.orange;
    return Colors.blue;
  }
}
