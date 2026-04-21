// lib/features/deadlines/presentation/screens/deadlines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      appBar: AppBar(title: const Text('Ø§Ù„Ù…ÙˆØ§Ø¹ÙŠØ¯ Ø§Ù„Ù†Ù‡Ø§Ø¦ÙŠØ©')),
      body: BlocBuilder<DeadlinesCubit, DeadlinesState>(
        builder: (ctx, state) {
          if (state is DeadlinesLoading) return const Center(child: CircularProgressIndicator());
          if (state is DeadlinesError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message),
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: () => ctx.read<DeadlinesCubit>().load(), child: const Text('Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©')),
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
                    border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _FilterTab(label: 'Ø§Ù„ÙƒÙ„', value: 'all', current: state.filter),
                      _FilterTab(label: 'Ù…Ù†ØªÙ‡ÙŠ', value: 'done', current: state.filter),
                      _FilterTab(label: 'Ù‚Ø§Ø¯Ù…', value: 'upcoming', current: state.filter),
                      _FilterTab(label: 'Ù…ØªØ£Ø®Ø±', value: 'overdue', current: state.filter),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ctx.read<DeadlinesCubit>().load(),
                    child: state.filtered.isEmpty
                        ? const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…ÙˆØ§Ø¹ÙŠØ¯'))
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                            itemCount: state.filtered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (_, i) {
                              final d = state.filtered[i] as Map<String, dynamic>? ?? {};
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
  const _FilterTab({required this.label, required this.value, required this.current});

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
    final name = data['documentName'] ?? data['name'] ?? 'Ù…Ø³ØªÙ†Ø¯';
    final deadline = data['deadline'] ?? '';
    final status = data['status'] ?? 'pending';

    Color statusColor;
    String statusLabel;
    switch (status.toString().toLowerCase()) {
      case 'overdue': statusColor = AppColors.error; statusLabel = 'Ù…ØªØ£Ø®Ø±'; break;
      case 'done': statusColor = AppColors.success; statusLabel = 'Ù…Ù†ØªÙ‡ÙŠ'; break;
      case 'upcoming': statusColor = AppColors.warning; statusLabel = 'Ù‚Ø§Ø¯Ù…'; break;
      default: statusColor = AppColors.blue; statusLabel = 'Ù‚ÙŠØ¯ Ø§Ù„ØªÙ†ÙÙŠØ°';
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
                child: Text('ØªØ­Ø¯ÙŠØ¯ Ø§Ù„Ù…ÙˆØ¹Ø¯', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.right),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(deadline),
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Theme.of(context).disabledColor),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.calendar_today_outlined, size: 13.sp, color: Theme.of(context).disabledColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return d; }
  }
}
