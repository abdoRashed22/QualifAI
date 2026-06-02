import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../presentation/cubit/reviewer_cubit.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

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
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'مرحباً بك في لوحة مراجعة الاعتماد',
                            textAlign: TextAlign.right,
                          ),
                        ),
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
                      final lastUploadDate =
                          _formatDate(college['lastUploadDate']);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AppCard(
                          onTap: () => context.go(AppRoutes.reviewerCollege
                              .replaceAll(':collegeId', '$id')),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCollegeImage(
                                      college['imagePath'] ?? college['logo']),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        if (lastUploadDate.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              'آخر رفع: $lastUploadDate',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
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
                      final id = _intValue(
                          item['id'] ?? item['collegeId'] ?? item['sectionId']);
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
                            onTap: id > 0
                                ? () => context.go(AppRoutes.reviewerCollege
                                    .replaceAll(':collegeId', '$id'))
                                : null,
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

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
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

  Widget _buildCollegeImage(dynamic imagePath) {
    final url = _resolveImagePath(imagePath);
    return Container(
      width: 58.w,
      height: 58.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: url.isEmpty
            ? Center(
                child: Icon(
                  Icons.account_balance,
                  size: 28.sp,
                  color: Colors.grey[700],
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.account_balance,
                    size: 28.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ),
      ),
    );
  }

  String _resolveImagePath(dynamic imagePath) {
    if (imagePath == null) return '';
    final path = imagePath.toString().trim();
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) {
      return 'https://qualifai.runasp.net$path';
    }
    return path;
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
