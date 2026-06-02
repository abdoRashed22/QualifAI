// lib/features/deadlines/presentation/screens/deadlines_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qualif_ai/core/router/app_router.dart';
import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/app_card.dart';

import '../cubit/deadlines_cubit.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeadlinesCubit>()..load(),
      child: const _DeadlinesView(),
    );
  }
}

class _DeadlinesView extends StatelessWidget {
  const _DeadlinesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المواعيد النهائية'),
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
      body: BlocBuilder<DeadlinesCubit, DeadlinesState>(
        builder: (ctx, state) {
          if (state is DeadlinesLoading)
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(width: 50.w, height: 40.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(width: double.infinity, height: 14.h, color: Colors.white),
                            SizedBox(height: 8.h),
                            Container(width: 80.w, height: 10.h, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          if (state is DeadlinesError) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(
                  onPressed: () => ctx.read<DeadlinesCubit>().load(),
                  child: const Text('إعادة المحاولة')),
            ]));
          }

          if (state is DeadlinesLoaded) {
            return Column(
              children: [
                // Filter tabs

                Container(
                  height: 44.h,
                  margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 0.5),
                  ),
                  child: Row(children: [
                    _FilterTab(
                        label: 'الكل', value: 'all', current: state.filter),
                    _FilterTab(
                        label: 'منتهي', value: 'done', current: state.filter),
                    _FilterTab(
                        label: 'قادم',
                        value: 'upcoming',
                        current: state.filter),
                    _FilterTab(
                        label: 'متأخر',
                        value: 'overdue',
                        current: state.filter),
                  ]),
                ),

                SizedBox(height: 8.h),

                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.cyan,
                    backgroundColor: AppColors.navyBlue,
                    strokeWidth: 3.0,
                    onRefresh: () async {
                      HapticFeedback.lightImpact();
                      await ctx.read<DeadlinesCubit>().load();
                    },
                    child: state.filtered.isEmpty
                        ? const Center(child: Text('لا توجد مواعيد'))
                        : ListView.separated(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                            itemCount: state.filtered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (_, i) {
                              final d =
                                  state.filtered[i] as Map<String, dynamic>? ??
                                      {};

                              return _DeadlineCard(data: d);
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label, value, current;

  const _FilterTab(
      {required this.label, required this.value, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = value == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<DeadlinesCubit>().filterBy(value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : Theme.of(context).disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DeadlineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['documentName'] ?? data['name'] ?? 'مستند';

    final deadline = data['deadline'] ?? '';

    final status = _normalizeStatus(data);

    Color statusColor;

    String statusLabel;
    switch (status) {
      case 'overdue':
        statusColor = AppColors.error;
        statusLabel = 'متأخر';
        break;
      case 'done':
        statusColor = AppColors.success;
        statusLabel = 'منتهي';
        break;
      case 'upcoming':
        statusColor = AppColors.warning;
        statusLabel = 'قادم';
        break;
      default:
        statusColor = AppColors.blue;
        statusLabel = 'قيد التنفيذ';
    }

    return AppCard(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(label: statusLabel, color: statusColor, small: true),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.navyBlue,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'تحديد الموعد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.right),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(deadline),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.calendar_today_outlined,
                        size: 13.sp, color: Theme.of(context).disabledColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeStatus(Map<String, dynamic> data) {
    final statusValue =
        (data['status'] ?? data['state'] ?? '').toString().toLowerCase();
    final completed = data['completed'] ?? data['isDone'] ?? data['done'];
    final isCompleted =
        completed == true || completed?.toString().toLowerCase() == 'true';

    if (statusValue.contains('done') ||
        statusValue.contains('completed') ||
        statusValue.contains('finished') ||
        statusValue.contains('complete') ||
        statusValue.contains('منتهي') ||
        statusValue.contains('مكتمل')) {
      return 'done';
    }
    if (statusValue.contains('overdue') ||
        statusValue.contains('late') ||
        statusValue.contains('متأخر') ||
        statusValue.contains('تأخر')) {
      return 'overdue';
    }
    if (statusValue.contains('upcoming') ||
        statusValue.contains('pending') ||
        statusValue.contains('قادم') ||
        statusValue.contains('قيد')) {
      return 'upcoming';
    }
    if (isCompleted) return 'done';

    final deadlineStr = data['deadline']?.toString() ?? '';
    final deadlineDate = DateTime.tryParse(deadlineStr);
    if (deadlineDate != null) {
      final now = DateTime.now();
      return deadlineDate.isBefore(now) ? 'overdue' : 'upcoming';
    }

    return 'upcoming';
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }
}
