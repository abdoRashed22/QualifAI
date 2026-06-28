// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

// ─── STATES ────────────────────────────────────────────────────────
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final int collegesCount;
  final int unreadNotifications;
  final int pendingReviewsCount;
  final List<dynamic> subscriptions;
  final List<dynamic> activityLog;

  const AdminDashboardLoaded({
    required this.collegesCount,
    required this.unreadNotifications,
    required this.pendingReviewsCount,
    required this.subscriptions,
    required this.activityLog,
  });

  @override
  List<Object?> get props => [
        collegesCount,
        unreadNotifications,
        pendingReviewsCount,
        subscriptions,
        activityLog,
      ];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── CUBIT ─────────────────────────────────────────────────────────
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final Dio _dio;

  AdminDashboardCubit(this._dio) : super(AdminDashboardLoading());

  Future<void> loadData() async {
    emit(AdminDashboardLoading());
    try {
      // Execute all API calls concurrently
      final responses = await Future.wait([
        _dio.get('/Colleges'),
        _dio.get('/Notification/unread-count'),
        _dio.get('/Quality/colleges'),
        _dio.get('/Subscription'),
        _dio.get('/ActivityLog'),
      ]);

      // 1. Colleges Count
      int collegesCount = _parseListLength(responses[0].data);

      // 2. Unread Notifications
      int unreadNotifications = _parseCount(responses[1].data);

      // 3. Pending Reviews
      int pendingReviewsCount = _parseListLength(responses[2].data);

      // 4. Subscriptions
      List<dynamic> subscriptions = _parseList(responses[3].data);

      // 5. Activity Log
      List<dynamic> activityLog = _parseList(responses[4].data);

      emit(AdminDashboardLoaded(
        collegesCount: collegesCount,
        unreadNotifications: unreadNotifications,
        pendingReviewsCount: pendingReviewsCount,
        subscriptions: subscriptions,
        activityLog: activityLog,
      ));
    } catch (e) {
      emit(const AdminDashboardError(
          'تعذر تحميل بيانات لوحة التحكم. تأكد من اتصالك.'));
    }
  }

  // Safe Parsing Helpers
  int _parseListLength(dynamic data) {
    if (data is List) return data.length;
    if (data is Map) {
      if (data['data'] is List) return (data['data'] as List).length;
      if (data['result'] is List) return (data['result'] as List).length;
    }
    return 0;
  }

  List<dynamic> _parseList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['result'] is List) return data['result'] as List;
    }
    return [];
  }

  int _parseCount(dynamic data) {
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    if (data is Map) {
      if (data['count'] != null)
        return int.tryParse(data['count'].toString()) ?? 0;
      if (data['unreadCount'] != null)
        return int.tryParse(data['unreadCount'].toString()) ?? 0;
      if (data['data'] != null)
        return int.tryParse(data['data'].toString()) ?? 0;
    }
    return 0;
  }
}

// ─── SCREEN WIDGET ─────────────────────────────────────────────────
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardCubit(sl<Dio>())..loadData(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
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
      body: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
        builder: (ctx, state) {
          if (state is AdminDashboardLoading) {
            return Shimmer.fromColors(
              baseColor: Theme.of(context).cardColor,
              highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Container(
                      height: 180.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r))),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r)))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                      height: 250.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r))),
                ],
              ),
            );
          }

          if (state is AdminDashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp)),
                  SizedBox(height: 16.h),
                  OutlinedButton(
                    onPressed: () => ctx.read<AdminDashboardCubit>().loadData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminDashboardLoaded) {
            // Parse Subscription Data
            int active = 0, suspended = 0, expired = 0;
            for (var sub in state.subscriptions) {
              final status = (sub['status'] ??
                      sub['subscriptionStatus'] ??
                      sub['statusName'] ??
                      '')
                  .toString()
                  .trim()
                  .toLowerCase();
              if (status == 'فعال' || status == 'active' || status == '1')
                active++;
              else if (status == 'موقوف' ||
                  status == 'suspended' ||
                  status == '2')
                suspended++;
              else if (status == 'منتهي' ||
                  status == 'expired' ||
                  status == '0') expired++;
            }
            final totalSubscriptions = active + suspended + expired;

            return RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.navyBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await ctx.read<AdminDashboardCubit>().loadData();
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                children: [
                  // ── SECTION 1: Welcome Card
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
                                'الجودة للجميع',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 12.h),
                              _buildBulletPoint(
                                  'رفع مستوى الأداء عبر كل مستوى'),
                              _buildBulletPoint('تعزيز ثقافة التحسين المستمر'),
                              _buildBulletPoint(
                                  'تمكين الأفراد من تقديم التميز'),
                              _buildBulletPoint(
                                  'بناء الثقة من خلال الوضوح والنزاهة'),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cyan,
                                  foregroundColor: AppColors.navyBlue,
                                  minimumSize: Size(130.w, 40.h),
                                ),
                                child: const Text('ابدأ رحلتك الجيدة'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Image.asset(
                          'assets/images/image2.png',
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, error, stackTrace) => Icon(
                              Icons.stars,
                              size: 80.sp,
                              color: AppColors.cyan),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── SECTION 2: Stats Cards
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: _StatCard(
                                title: 'طلبات تقييم الاعتماد',
                                value: '${state.pendingReviewsCount}',
                                color: AppColors.warning)),
                        SizedBox(width: 8.w),
                        Expanded(
                            child: _StatCard(
                                title: 'اشعارات جديدة',
                                value: '${state.unreadNotifications}',
                                color: AppColors.info)),
                        SizedBox(width: 8.w),
                        Expanded(
                            child: _StatCard(
                                title: 'الكليات المسجلة',
                                value: '${state.collegesCount}',
                                color: AppColors.success)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── السكشن الجديد: Static Bar Chart
                  // _buildStaticBarChart(context),
                  //SizedBox(height: 16.h),
// الـ Chart الخطي الجديد
                  _buildStaticLineChart(context),
                  SizedBox(height: 16.h),
                  // ── SECTION 3: Pie Chart
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('نسبة الكليات المعتمدة',
                            style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 24.h),
                        if (totalSubscriptions == 0)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: const Center(
                                child: Text('لا توجد اشتراكات مسجلة',
                                    style: TextStyle(fontFamily: 'Cairo'))),
                          )
                        else ...[
                          SizedBox(
                            height: 180.h,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  if (active > 0)
                                    PieChartSectionData(
                                        color: AppColors.success,
                                        value: active.toDouble(),
                                        title: '$active',
                                        radius: 45,
                                        titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  if (suspended > 0)
                                    PieChartSectionData(
                                        color: AppColors.warning,
                                        value: suspended.toDouble(),
                                        title: '$suspended',
                                        radius: 45,
                                        titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  if (expired > 0)
                                    PieChartSectionData(
                                        color: AppColors.error,
                                        value: expired.toDouble(),
                                        title: '$expired',
                                        radius: 45,
                                        titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend('فعال', AppColors.success),
                              SizedBox(width: 16.w),
                              _buildLegend('موقوف', AppColors.warning),
                              SizedBox(width: 16.w),
                              _buildLegend('منتهي', AppColors.error),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── SECTION 4: Recent Activity
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('آخر الأنشطة',
                            style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 12.h),
                        if (state.activityLog.isEmpty)
                          const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('لا توجد أنشطة مسجلة',
                                      style: TextStyle(fontFamily: 'Cairo'))))
                        else
                          ...state.activityLog.take(5).map((log) {
                            final actionText = log['action'] ??
                                log['description'] ??
                                'نشاط غير معروف';
                            final timestamp = log['lastModifiedFormatted'] ??
                                log['timestamp'] ??
                                log['createdAt'] ??
                                '';
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(actionText,
                                            style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 13.sp),
                                            textAlign: TextAlign.right),
                                        if (timestamp.toString().isNotEmpty)
                                          Text(timestamp,
                                              style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 11.sp,
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                              textAlign: TextAlign.right),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Icon(Icons.history,
                                      size: 20.sp, color: AppColors.blue),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── SECTION 5: Subscription Progress Bars
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('حالة الاشتراكات الكلية',
                            style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 16.h),
                        _buildProgressBar(context, 'نسبة الاشتراكات النشطة',
                            active, totalSubscriptions, AppColors.success),
                        SizedBox(height: 12.h),
                        _buildProgressBar(context, 'نسبة الاشتراكات الموقوفة',
                            suspended, totalSubscriptions, AppColors.warning),
                        SizedBox(height: 12.h),
                        _buildProgressBar(context, 'نسبة الاشتراكات المنتهية',
                            expired, totalSubscriptions, AppColors.error),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // UI Builders
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: Text(text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      fontFamily: 'Cairo'))),
          SizedBox(width: 8.w),
          Icon(Icons.check_circle, color: AppColors.success, size: 16.sp),
        ],
      ),
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo')),
        SizedBox(width: 6.w),
        Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildProgressBar(
      BuildContext context, String title, int count, int total, Color color) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(pct * 100).round()}%',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 13.sp)),
            Text(title, style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo')),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Cairo',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

Widget _buildStaticBarChart(BuildContext context) {
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'معدل تقديم طلبات الاعتماد (آخر 6 أشهر)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 180.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navyBlue,
                  tooltipBorder:
                      const BorderSide(color: AppColors.cyan, width: 1),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} طلب',
                      TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'يناير',
                        'فبراير',
                        'مارس',
                        'أبريل',
                        'مايو',
                        'يونيو'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeBarGroup(0, 8, AppColors.blue),
                _makeBarGroup(1, 14, AppColors.cyan),
                _makeBarGroup(2, 11, AppColors.success),
                _makeBarGroup(3, 18, AppColors.warning),
                _makeBarGroup(4, 9, AppColors.info),
                _makeBarGroup(5, 15, AppColors.blue),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

BarChartGroupData _makeBarGroup(int x, double y, Color color) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 14.w,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(6.r),
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 20,
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
    ],
  );
}

//------------------------------------------------------------
Widget _buildStaticLineChart(BuildContext context) {
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'منحنى نشاط النظام وتقديم الطلبات',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 180.h,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.navyBlue,
                  tooltipBorder:
                      const BorderSide(color: AppColors.cyan, width: 1),
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y.toInt()} طلب',
                        TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(
                  show: false), // إبقاء الخلفية نظيفة بدون خطوط شبكية مكدسة
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'يناير',
                        'فبراير',
                        'مارس',
                        'أبريل',
                        'مايو',
                        'يونيو'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: 20,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 6),
                    FlSpot(1, 14),
                    FlSpot(2, 10),
                    FlSpot(3, 18),
                    FlSpot(4, 12),
                    FlSpot(5, 16),
                  ],
                  isCurved: true, // يجعل المنحنى انسيابي وناعم
                  curveSmoothness: 0.35,
                  color: AppColors.cyan,
                  barWidth: 4.w,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    show:
                        true, // إظهار النقاط الدائرية عند كل شهر لسهولة القراءة
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.cyan.withOpacity(
                        0.15), // تعبئة خفيفة تحت المنحنى تعطي مظهراً رائعاً
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
