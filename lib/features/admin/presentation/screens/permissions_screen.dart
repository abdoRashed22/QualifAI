import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/admin_cubit.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadPermissionsOnly(),
      child: const _PermissionsView(),
    );
  }
}

class _PermissionsView extends StatelessWidget {
  const _PermissionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الصلاحيات الشاملة',
            style: TextStyle(fontFamily: 'Cairo')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: 8,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            );
          }

          if (state is PermissionsLoadedList) {
            final perms = state.permissions;

            if (perms.isEmpty) {
              return const Center(
                child: Text('لا توجد صلاحيات متاحة في النظام',
                    style: TextStyle(fontFamily: 'Cairo')),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: perms.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final p = perms[index] as Map<String, dynamic>? ?? {};
                final pId = p['id'] ?? p['permissionId'] ?? index + 1;
                final pName = p['name'] ?? p['permissionName'] ?? 'صلاحية $pId';
                final pDesc = p['description'] ??
                    'لا يوجد وصف متوفر لهذه الصلاحية في النظام.';

                return AppCard(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_user_outlined,
                            color: AppColors.navyBlue, size: 20.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(pName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right),
                            SizedBox(height: 4.h),
                            Text(pDesc,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.right),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is AdminError)
            return Center(
                child: Text(state.message,
                    style: const TextStyle(fontFamily: 'Cairo')));

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
