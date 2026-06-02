// lib/features/admin/presentation/screens/activity_log_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../cubit/admin_cubit.dart';

// ── ActivityLogScreen ─────────────────────────────────────────────────────────

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<AdminCubit>()..loadActivityLog(),
        child: const _ActivityView());
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الأنشطة'),
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
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is ActivityLoaded) {
            if (state.logs.isEmpty)
              return const Center(child: Text('لا توجد أنشطة'));

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.logs.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 0.5.h, thickness: 0.5),
              itemBuilder: (_, i) {
                final log = state.logs[i] as Map<String, dynamic>? ?? {};

                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                          Text(
                              log['employeeName'] ??
                                  log['userName'] ??
                                  "مستخدم",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),

                          SizedBox(height: 2.h),

                          // ✅ FIX: show role from log

                          if ((log['role'] ?? '').toString().isNotEmpty)
                            Text(log['role'].toString(),
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    color: AppColors.blue)),

                          SizedBox(height: 4.h),

                          Text(log['action'] ?? log['description'] ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.right),

                          SizedBox(height: 4.h),

                          // ✅ FIX: API بيبعت 'lastModifiedFormatted' مش 'timestamp' أو 'createdAt'

                          Text(
                            log['lastModifiedFormatted'] ??
                                log['timestamp'] ??
                                log['createdAt'] ??
                                '',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: Theme.of(context).disabledColor),
                          ),
                        ])),
                    SizedBox(width: 12.w),
                    Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Icon(Icons.history,
                            size: 18.sp, color: AppColors.blue)),
                  ]),
                );
              },
            );
          }

          if (state is AdminError) return Center(child: Text(state.message));

          return const SizedBox();
        },
      ),
    );
  }
}
