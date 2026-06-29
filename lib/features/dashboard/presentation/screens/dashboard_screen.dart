import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DashboardCubit>();
    _cubit.load(1);
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value does NOT close the cubit when widget disposes
    return BlocProvider.value(
      value: _cubit,
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = sl<HiveCache>().getUserData();
    final firstName = userData?['firstName'] ?? 'مستخدم';
    final role = sl<HiveCache>().getRole() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
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
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (ctx, state) {
          if (state is DashboardLoading) {
            return Shimmer.fromColors(
              baseColor: Theme.of(context).cardColor,
              highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Container(
                      height: 110.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r))),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 90.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: Container(
                              height: 90.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: Container(
                              height: 90.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                      height: 220.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r))),
                ],
              ),
            );
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
                    child: const Text('إعادة المحاولة'),
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
            color: AppColors.cyan,
            backgroundColor: AppColors.navyBlue,
            strokeWidth: 3.0,
            onRefresh: () async {
              HapticFeedback.lightImpact(); // اهتزاز خفيف وجميل
              await ctx.read<DashboardCubit>().load(1);
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              children: [
                // ── Welcome Card ──────────────────────────
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
                              'مرحباً$firstName ',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            //  SizedBox(height: 4.h),
                            Text(
                              _roleLabel(role),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: Colors.white60,
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Image.asset('assets/images/2 51.png',
                          width: 64.w, height: 64.h),
                      //   Text('🤖', style: TextStyle(fontSize: 44.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Stats Row ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'درجة الاكتمال',
                        value: '${(overallPct * 100).round()}%',
                        color: _pctColor(overallPct),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'الملفات المرفوعة',
                        value: '$totalUploaded',
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatCard(
                        label: 'المعايير',
                        value: '${sections.length}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Chart Card ────────────────────────────
                if (sections.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'الامتثال للمعايير',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          height: 200
                              .h, // زيادات طفيفة في الارتفاع لتناسب خطوط المقياس
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              // 1. تفعيل التفاعل وإظهار Tooltip مخصص عند الضغط على العمود
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.navyBlue,
                                  tooltipBorder: const BorderSide(
                                      color: AppColors.cyan, width: 1),
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final sectionName =
                                        sections[group.x.toInt()].name;
                                    return BarTooltipItem(
                                      '$sectionName\n',
                                      TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'نسبة الإنجاز: ${rod.toY.round()}%',
                                          style: TextStyle(
                                            color: rod.color,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                // عناوين المحور السفلي (أرقام المعايير فقط بدون حرف م)
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (val, meta) {
                                      final i = val.toInt();
                                      if (i >= sections.length)
                                        return const SizedBox();
                                      return Padding(
                                        padding: EdgeInsets.only(top: 6.h),
                                        child: Text(
                                          '${i + 1}', // تم إزالة حرف الـ "م" ليظهر الرقم فقط (1، 2، 3...)
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // إظهار مقياس نسبي على اليسار لتوضيح مستويات الأداء المرجعية
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 35,
                                    interval:
                                        50, // إظهار القيم عند 0، 50، 100 فقط لمنع الازدحام
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}%',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 10.sp,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              // تم تعيين show إلى false لإخفاء الخط الرمادي العرضي تماماً عند 50%
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: sections.asMap().entries.map((e) {
                                final pct = (e.value.completionPercent * 100);
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: pct,
                                      color:
                                          _pctColor(e.value.completionPercent),
                                      width: 16
                                          .w, // عرض متناسق ومستجيب للشاشات المختلفة
                                      // تم تعديلها لتصبح دائرية من جميع الجهات (فوق وتحت)
                                      borderRadius: BorderRadius.circular(5.r),
                                      // إضافة مجرى خلفي شفاف (Track) يوضح الحد الأقصى للعمود (%100)
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        show: true,
                                        toY: 100,
                                        color: Theme.of(context)
                                            .disabledColor
                                            .withOpacity(0.08),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
                SizedBox(height: 16.h),

                /*       // ── Chart Card ────────────────────────────
                if (sections.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('الامتثال للمعايير',
                            style: Theme.of(context).textTheme.titleMedium),
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
                                      if (i >= sections.length) {
                                        return const SizedBox();
                                      }
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
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
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
                                      color:
                                          _pctColor(e.value.completionPercent),
                                      width: 20.w,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4.r)),
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
*/
                // ── Standards List ────────────────────────
                AppCard(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('المعايير',
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 12.h),
                      if (sections.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: Text(
                              'لا توجد بيانات',
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
      case 'system_admin':
        return 'مدير النظام';
      case 'quality_manager':
        return 'مديرة الجودة';
      case 'quality_employee':
        return 'موظف الجودة';
      case 'reviewer':
        return 'المراجع';
      default:
        return role;
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

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: AppCard(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
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
    final color = pct >= 0.7
        ? AppColors.success
        : pct >= 0.4
            ? AppColors.warning
            : AppColors.error;

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
