// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
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
        title: const Text('Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (ctx, state) => TextButton(
              onPressed: state is NotificationLoaded
                  ? () => ctx.read<NotificationCubit>().markAllRead()
                  : null,
              child: Text(
                'ØªÙ…ÙŠÙŠØ² Ø§Ù„ÙƒÙ„ ÙƒÙ…Ù‚Ø±ÙˆØ¡',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: AppColors.cyan,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (ctx, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () => ctx.read<NotificationCubit>().loadNotifications(),
                    child: const Text('Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©'),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ðŸ””', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¥Ø´Ø¹Ø§Ø±Ø§Øª'),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<NotificationCubit>().loadNotifications(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => Divider(height: 0.5.h, thickness: 0.5),
                itemBuilder: (_, i) {
                  final n = state.notifications[i] as Map<String, dynamic>? ?? {};
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
    final title = data['title'] as String? ?? 'Ø¥Ø´Ø¹Ø§Ø±';
    final message = data['message'] as String? ?? '';
    final time = data['createdAt'] as String? ?? '';

    return Container(
      color: isRead
          ? null
          : AppColors.blue.withOpacity(0.05),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRead)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 8.w),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (time.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _notifIcon(data['type'] as String? ?? ''),
        ],
      ),
    );
  }

  Widget _notifIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'deadline': icon = Icons.schedule; color = AppColors.warning; break;
      case 'report': icon = Icons.bar_chart; color = AppColors.blue; break;
      case 'file': icon = Icons.upload_file; color = AppColors.success; break;
      case 'warning': icon = Icons.warning_amber_outlined; color = AppColors.error; break;
      default: icon = Icons.notifications_outlined; color = AppColors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return 'Ù…Ù†Ø° ${diff.inMinutes} Ø¯Ù‚ÙŠÙ‚Ø©';
      if (diff.inHours < 24) return 'Ù…Ù†Ø° ${diff.inHours} Ø³Ø§Ø¹Ø©';
      return 'Ù…Ù†Ø° ${diff.inDays} ÙŠÙˆÙ…';
    } catch (_) { return iso; }
  }
}
