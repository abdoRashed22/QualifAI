// lib/features/notifications/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qualif_ai/features/profile/data/remote/side_rail_navigation.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/theme/app_colors.dart';

import '../cubit/notification_cubit.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationCubit>()..startPolling(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) {
            final sideRail = SideRailNavigation.of(ctx);
            if (sideRail != null) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => sideRail.openDrawer(),
              );
            }
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            );
          },
        ),
        title: Text('الإشعارات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (ctx, state) => TextButton(
              onPressed: state is NotificationLoaded
                  ? () => ctx.read<NotificationCubit>().markAllRead()
                  : null,
              child: Text(
                'تمييز الكل كمقروء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyan,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (ctx, state) {
          if (state is NotificationLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.cyan));
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp)),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () =>
                        ctx.read<NotificationCubit>().loadNotifications(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_off_outlined,
                          size: 64.sp, color: AppColors.cyan.withOpacity(0.5)),
                    ),
                    SizedBox(height: 24.h),
                    Text('لا توجد إشعارات حالياً',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    Text('أنت على اطلاع بكل جديد!',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            color: Theme.of(context).disabledColor)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.cyan,
              onRefresh: () =>
                  ctx.read<NotificationCubit>().loadNotifications(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1.h,
                    thickness: 0.5,
                    indent: 76.w, // لمحاذاة الخط مع النص بدلاً من الأيقونة
                    endIndent: 16.w),
                itemBuilder: (_, i) {
                  final n =
                      state.notifications[i] as Map<String, dynamic>? ?? {};

                  final isRead = n['isRead'] as bool? ?? true;

                  return _NotificationTile(data: n, isRead: isRead);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;

  final bool isRead;

  const _NotificationTile({required this.data, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = data['title'] as String? ?? 'إشعار';

    final message = data['message'] as String? ?? '';

    final time = data['createdAt'] as String? ?? '';

    return Material(
      color: isRead ? Colors.transparent : AppColors.cyan.withOpacity(0.04),
      child: InkWell(
        onTap: () {
          // يمكنك إضافة توجيه (Navigation) هنا بناءً على نوع الإشعار
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة (على اليمين في الواجهة العربية)
              _notifIcon(data['type'] as String? ?? '', theme),
              SizedBox(width: 12.w),

              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.sp,
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.w800,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatTime(time),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color:
                                isRead ? theme.disabledColor : AppColors.cyan,
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (message.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // مؤشر الإشعار غير المقروء (النقطة الزرقاء على اليسار)
              if (!isRead) ...[
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifIcon(String type, ThemeData theme) {
    IconData icon;

    Color color;

    switch (type.toLowerCase()) {
      case 'deadline':
        icon = Icons.schedule;
        color = AppColors.warning;
        break;

      case 'report':
        icon = Icons.bar_chart;
        color = AppColors.blue;
        break;

      case 'file':
        icon = Icons.upload_file;
        color = AppColors.success;
        break;

      case 'warning':
        icon = Icons.warning_amber_outlined;
        color = AppColors.error;
        break;

      default:
        icon = Icons.notifications_active_outlined;
        color = AppColors.cyan;
    }

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        color: isRead ? theme.cardColor : color.withOpacity(0.12),
        border: isRead
            ? Border.all(color: theme.dividerColor.withOpacity(0.5))
            : null,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon,
            size: 22.sp, color: isRead ? theme.disabledColor : color),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();

      final now = DateTime.now();

      final diff = now.difference(dt);

      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';

      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';

      return 'منذ ${diff.inDays} يوم';
    } catch (_) {
      return iso;
    }
  }
}
