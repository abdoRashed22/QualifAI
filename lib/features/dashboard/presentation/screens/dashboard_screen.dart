// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final userData = sl<HiveCache>().getUserData();
    final firstName = userData?['firstName'] ?? 'Ù…Ø³ØªØ®Ø¯Ù…';
    final role = sl<HiveCache>().getRole() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø§Ù„ØµÙØ­Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (ctx, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  OutlinedButton(
                    onPressed: () => ctx.read<DashboardCubit>().load(),
                    child: const Text('Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©'),
                  ),
                ],
              ),
            );
          }

          final loaded = state is DashboardLoaded ? state : null;
          final overallPct = loaded?.overallCompletion ?? 0.0;
          final totalUploaded = loaded?.totalUploaded ?? 0;
          final sections = loaded?.sections ?? [];

          return RefreshIndicator(
            onRefresh: () => ctx.read<DashboardCubit>().load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              children: [
                // â”€â”€ Welcome Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Ù…Ø±Ø­Ø¨Ø§Ù‹ØŒ $firstName ðŸ‘‹',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _roleLabel(role),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: Colors.white60,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Ø¢Ø®Ø± ØªØ­Ø¯ÙŠØ«: Ø§Ù„ÙŠÙˆÙ…',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text('ðŸ¤–', style: TextStyle(fontSize: 44.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // â”€â”€ Stats Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Ø¯Ø±Ø¬Ø© Ø§Ù„Ø§ÙƒØªÙ…Ø§Ù„',
                        value: '${(overallPct * 100).round()}%',
                        color: _pctColor(overallPct),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'Ø§Ù„Ù…Ù„ÙØ§Øª Ø§Ù„Ù…Ø±ÙÙˆØ¹Ø©',
                        value: '$totalUploaded',
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'Ø§Ù„Ù…Ø¹Ø§ÙŠÙŠØ±',
                        value: '${sections.length}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // â”€â”€ Chart Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (sections.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Ø§Ù„Ø§Ù…ØªØ«Ø§Ù„ Ù„Ù„Ù…Ø¹Ø§ÙŠÙŠØ±', style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 180.h,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      final i = val.toInt();
                                      if (i >= sections.length) return const SizedBox();
                                      return Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(fontSize: 10.sp),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: Theme.of(context).dividerColor,
                                  strokeWidth: 0.5,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: sections.asMap().entries.map((e) {
                                final pct = (e.value.completionPercent * 100);
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: pct,
                                      color: _pctColor(e.value.completionPercent),
                                      width: 20.w,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // â”€â”€ Standards List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                AppCard(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Ø§Ù„Ù…Ø¹Ø§ÙŠÙŠØ±', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 12.h),
                      if (sections.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: Text(
                              'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨ÙŠØ§Ù†Ø§Øª',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                      else
                        ...sections.map((s) => _StandardRow(section: s)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'system_admin': return 'Ù…Ø¯ÙŠØ± Ø§Ù„Ù†Ø¸Ø§Ù…';
      case 'quality_manager': return 'Ù…Ø¯ÙŠØ±Ø© Ø§Ù„Ø¬ÙˆØ¯Ø©';
      case 'quality_employee': return 'Ù…ÙˆØ¸Ù Ø§Ù„Ø¬ÙˆØ¯Ø©';
      case 'reviewer': return 'Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹';
      default: return role;
    }
  }

  Color _pctColor(double pct) {
    if (pct >= 0.7) return AppColors.success;
    if (pct >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StandardRow extends StatelessWidget {
  final SectionSummary section;
  const _StandardRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final pct = section.completionPercent;
    final color = pct >= 0.7 ? AppColors.success : pct >= 0.4 ? AppColors.warning : AppColors.error;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(section.name, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 6.h),
          AppProgressBar(value: pct),
        ],
      ),
    );
  }
}
