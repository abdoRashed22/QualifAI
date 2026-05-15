import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../presentation/cubit/reviewer_cubit.dart';

class ReviewerDashboardScreen extends StatefulWidget {
  const ReviewerDashboardScreen({super.key});

  @override
  State<ReviewerDashboardScreen> createState() =>
      _ReviewerDashboardScreenState();
}

class _ReviewerDashboardScreenState extends State<ReviewerDashboardScreen> {
  late final ReviewerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReviewerCubit>();
    _cubit.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const _ReviewerDashboardView(),
    );
  }
}

class _ReviewerDashboardView extends StatelessWidget {
  const _ReviewerDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المراجعة'),
      ),
      body: BlocBuilder<ReviewerCubit, ReviewerState>(
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
                    onPressed: () =>
                        context.read<ReviewerCubit>().loadDashboard(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is ReviewerDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ReviewerCubit>().loadDashboard(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                children: [
                  AppCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('مرحباً بك في لوحة مراجعة الاعتماد'),
                        SizedBox(height: 8.h),
                        Text(
                          'هنا تجد الكليات المخصصة لك والملاحظات الحديثة',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey[600]),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _StatInfo(
                                label: 'الكليات المكلفة',
                                value: '${state.totalAssigned}',
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _StatInfo(
                                label: 'قيد المراجعة',
                                value: '${state.pendingReviews}',
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _StatInfo(
                                label: 'المراجعات المكتملة',
                                value: '${state.completedReviews}',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text('الكليات المخصصة للمراجعة',
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 12.h),
                  if (state.assignedColleges.isEmpty)
                    AppCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined, size: 48),
                            SizedBox(height: 12.h),
                            const Text('لا توجد كليات مخصصة للمراجعة حالياً'),
                          ],
                        ),
                      ),
                    )
                  else
                    ...state.assignedColleges.map((college) {
                      final id =
                          _intValue(college['id'] ?? college['collegeId']);
                      final name = _stringValue(college['name'] ??
                          college['collegeName'] ??
                          college['college']);
                      final status = _statusLabel(college);
                      final badgeColor = _statusColor(status);
                      final type = _stringValue(college['accreditationType'] ??
                          college['type'] ??
                          '');
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          onTap: () => context.go(AppRoutes.reviewerCollege
                              .replaceAll(':collegeId', '$id')),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                  ),
                                  AppBadge(label: status, color: badgeColor),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                alignment: WrapAlignment.end,
                                children: [
                                  if (type.isNotEmpty)
                                    AppBadge(
                                        label: 'نوع الاعتماد: $type',
                                        color: Colors.blueGrey),
                                  AppBadge(
                                      label: 'المراجعة الأخيرة',
                                      color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (state.recentActivity.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Text('آخر النشاطات',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 12.h),
                    ...state.recentActivity.map((item) {
                      final title = _stringValue(
                          item['name'] ?? item['collegeName'] ?? item['title']);
                      final subtitle =
                          _stringValue(item['status'] ?? item['reviewStatus']);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(title),
                            subtitle: Text(subtitle),
                            trailing: const Icon(Icons.chevron_left),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

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

  Color _statusColor(String status) {
    if (status == 'معتمد') return Colors.green;
    if (status == 'مرفوض') return Colors.red;
    if (status == 'يحتاج تعديل') return Colors.orange;
    return Colors.blue;
  }
}

class _StatInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: color)),
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
