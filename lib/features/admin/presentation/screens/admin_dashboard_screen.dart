// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/static_line_chart.dart';
import '../widgets/admin_dashboard_helpers.dart';

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
            return _buildLoadingState(context);
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
            return _buildLoadedState(context, state, ctx);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
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

  Widget _buildLoadedState(BuildContext context, AdminDashboardLoaded state,
      BuildContext cubitContext) {
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
      else if (status == 'موقوف' || status == 'suspended' || status == '2')
        suspended++;
      else if (status == 'منتهي' || status == 'expired' || status == '0')
        expired++;
    }
    final totalSubscriptions = active + suspended + expired;

    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.navyBlue,
      strokeWidth: 3.0,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await cubitContext.read<AdminDashboardCubit>().loadData();
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
                      buildBulletPoint('رفع مستوى الأداء عبر كل مستوى'),
                      buildBulletPoint('تعزيز ثقافة التحسين المستمر'),
                      buildBulletPoint('تمكين الأفراد من تقديم التميز'),
                      buildBulletPoint('بناء الثقة من خلال الوضوح والنزاهة'),
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
                  errorBuilder: (ctx, error, stackTrace) =>
                      Icon(Icons.stars, size: 80.sp, color: AppColors.cyan),
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
                    child: StatCard(
                        title: 'طلبات تقييم الاعتماد',
                        value: '${state.pendingReviewsCount}',
                        color: AppColors.warning)),
                SizedBox(width: 8.w),
                Expanded(
                    child: StatCard(
                        title: 'اشعارات جديدة',
                        value: '${state.unreadNotifications}',
                        color: AppColors.info)),
                SizedBox(width: 8.w),
                Expanded(
                    child: StatCard(
                        title: 'الكليات المسجلة',
                        value: '${state.collegesCount}',
                        color: AppColors.success)),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── الـ Chart الخطي
          buildStaticLineChart(context),
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
                      buildLegend('فعال', AppColors.success),
                      SizedBox(width: 16.w),
                      buildLegend('موقوف', AppColors.warning),
                      SizedBox(width: 16.w),
                      buildLegend('منتهي', AppColors.error),
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
                    final actionText =
                        log['action'] ?? log['description'] ?? 'نشاط غير معروف';
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(actionText,
                                    style: TextStyle(
                                        fontFamily: 'Cairo', fontSize: 13.sp),
                                    textAlign: TextAlign.right),
                                if (timestamp.toString().isNotEmpty)
                                  Text(timestamp,
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11.sp,
                                          color:
                                              Theme.of(context).disabledColor),
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
                buildProgressBar(context, 'نسبة الاشتراكات النشطة', active,
                    totalSubscriptions, AppColors.success),
                SizedBox(height: 12.h),
                buildProgressBar(context, 'نسبة الاشتراكات الموقوفة', suspended,
                    totalSubscriptions, AppColors.warning),
                SizedBox(height: 12.h),
                buildProgressBar(context, 'نسبة الاشتراكات المنتهية', expired,
                    totalSubscriptions, AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
