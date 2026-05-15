import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_badge.dart';
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
              final status = _statusLabel(college);
              final type = _stringValue(
                  college['accreditationType'] ?? college['type'] ?? '');
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
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppBadge(
                                label: 'الحالة: $status',
                                color: _statusColor(status)),
                            AppBadge(
                                label: type.isNotEmpty
                                    ? 'نوع الاعتماد: $type'
                                    : 'نوع غير محدد',
                                color: Colors.blueGrey),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _metricTile('عدد المعايير', '${sections.length}'),
                            SizedBox(width: 10.w),
                            _metricTile(
                                'المراجعات', '${_completedCount(sections)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                                      child:
                                          Text('انقر لعرض الملفات والتعليقات')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                            if (value != null)
                              setState(() => _selectedStatus = value);
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

  String _statusLabel(dynamic college) {
    final raw = college is Map
        ? college['status'] ?? college['reviewStatus'] ?? college['statusName']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('approve') || value.contains('موافق')) return 'معتمد';
    if (value.contains('reject') || value.contains('رفض')) return 'مرفوض';
    if (value.contains('revision') || value.contains('تعديل'))
      return 'يحتاج تعديل';
    return 'قيد المراجعة';
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
    if (value.contains('revision') || value.contains('تعديل'))
      return 'يحتاج تعديل';
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
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
