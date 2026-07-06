// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/cache/hive_cache.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_helpers.dart';
import '../widgets/dashboard_charts.dart';

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
            return _buildLoadingState(context);
          }
          if (state is DashboardError) {
            return _buildErrorState(context, ctx, state);
          }

          final loaded = state is DashboardLoaded ? state : null;
          if (loaded == null) {
            return const SizedBox.shrink();
          }

          return _buildLoadedState(context, ctx, loaded, firstName, role);
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

  Widget _buildErrorState(
      BuildContext context, BuildContext ctx, DashboardError state) {
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

  Widget _buildLoadedState(
    BuildContext context,
    BuildContext ctx,
    DashboardLoaded loaded,
    String firstName,
    String role,
  ) {
    final overallPct = loaded.overallCompletion;
    final totalUploaded = loaded.totalUploaded;
    final sections = loaded.sections;

    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.navyBlue,
      strokeWidth: 3.0,
      onRefresh: () async {
        HapticFeedback.lightImpact();
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
                      Text(
                        roleLabel(role),
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
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ── Stats Row ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'درجة الاكتمال',
                  value: '${(overallPct * 100).round()}%',
                  color: pctColor(overallPct),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: StatCard(
                  label: 'الملفات المرفوعة',
                  value: '$totalUploaded',
                  color: AppColors.blue,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: StatCard(
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
            buildComplianceChart(context, sections),
            SizedBox(height: 16.h),
          ],

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
                  ...sections.map((s) => StandardRow(
                        section: s,
                        color: pctColor(s.completionPercent),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
