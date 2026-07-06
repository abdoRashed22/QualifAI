// lib/features/reviewer/presentation/screens/reviewer_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../presentation/cubit/reviewer_cubit.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../widgets/stat_info.dart';
import '../widgets/meta_chip.dart';
import '../widgets/colleges_line_chart.dart';
import '../widgets/reviewer_helpers.dart';

class ReviewerDashboardScreen extends StatefulWidget {
  const ReviewerDashboardScreen({super.key});

  @override
  State<ReviewerDashboardScreen> createState() =>
      _ReviewerDashboardScreenState();
}

class _ReviewerDashboardScreenState extends State<ReviewerDashboardScreen> {
  late final ReviewerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReviewerCubit>();
    _cubit.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: const _ReviewerDashboardView(),
    );
  }
}

class _ReviewerDashboardView extends StatelessWidget {
  const _ReviewerDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المراجعة'),
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
      body: BlocBuilder<ReviewerCubit, ReviewerState>(
        builder: (context, state) {
          if (state is ReviewerLoading) {
            return _buildLoadingState(context);
          }

          if (state is ReviewerError) {
            return _buildErrorState(context, state);
          }

          if (state is ReviewerDashboardLoaded) {
            return _buildLoadedState(context, state);
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
              height: 140.h,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r))),
          SizedBox(height: 20.h),
          Container(height: 20.h, width: 150.w, color: Colors.white),
          SizedBox(height: 12.h),
          buildShimmerCard(120.h),
          SizedBox(height: 12.h),
          buildShimmerCard(120.h),
          SizedBox(height: 12.h),
          buildShimmerCard(120.h),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ReviewerError state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 12.h),
          Text(state.message, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReviewerCubit>().loadDashboard(),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, ReviewerDashboardLoaded state) {
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.navyBlue,
      strokeWidth: 3.0,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await context.read<ReviewerCubit>().loadDashboard();
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          // ── Welcome + stats card ──
          AppCard(
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'مرحباً بك في لوحة مراجعة الاعتماد',
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'هنا تجد الكليات المخصصة لك والملاحظات الحديثة',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: StatInfo(
                        label: 'الكليات المكلفة',
                        value: '${state.totalAssigned}',
                        color: Colors.blue,
                        icon: Icons.school_outlined,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatInfo(
                        label: 'قيد المراجعة',
                        value: '${state.pendingReviews}',
                        color: Colors.orange,
                        icon: Icons.hourglass_top_outlined,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatInfo(
                        label: 'المكتملة',
                        value: '${state.completedReviews}',
                        color: Colors.green,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Chart Card ────────────────────────────
          if (state.assignedColleges.isNotEmpty) ...[
            SizedBox(height: 20.h),
            buildCollegesLineChart(
              context,
              state.assignedColleges,
              stringValue: stringValue,
            ),
          ],

          SizedBox(height: 20.h),

          // ── Section title ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.assignedColleges.length} كلية',
                style:
                    TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              ),
              Text(
                'الكليات المخصصة للمراجعة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── College cards ──
          if (state.assignedColleges.isEmpty)
            AppCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28.h),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey[400]),
                    SizedBox(height: 12.h),
                    Text('لا توجد كليات مخصصة للمراجعة حالياً',
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            )
          else
            ...state.assignedColleges.map((college) {
              return _buildCollegeCard(context, college, state);
            }),

          // ── Recent activity ──
          if (state.recentActivity.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text('آخر النشاطات',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(height: 12.h),
            ...state.recentActivity.map((item) {
              final id =
                  intValue(item['id'] ?? item['collegeId'] ?? item['sectionId']);
              final title = stringValue(
                  item['name'] ?? item['collegeName'] ?? item['title']);
              final subtitle =
                  stringValue(item['status'] ?? item['reviewStatus']);
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: AppCard(
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w),
                    title: Text(title),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: id > 0
                        ? () => context.go(AppRoutes.reviewerCollege
                            .replaceAll(':collegeId', '$id'))
                        : null,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCollegeCard(
    BuildContext context,
    dynamic college,
    ReviewerDashboardLoaded state,
  ) {
    final id = intValue(college['id'] ?? college['collegeId']);
    final name = stringValue(
        college['name'] ?? college['collegeName'] ?? college['college']);
    final university = stringValue(college['university'] ?? '');
    final institutionType = stringValue(college['institutionType'] ?? '');
    final accreditationType = stringValue(
        college['accreditationType'] ?? college['type'] ?? '');
    final readiness =
        (college['readinessPercentage'] as num?)?.toDouble() ?? 0.0;
    final status = statusLabel(college);
    final badgeColor = statusColor(status);
    final lastUploadDate = formatDate(college['lastUploadDate']);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AppCard(
        borderRadius: 16,
        onTap: () =>
            context.go(AppRoutes.reviewerCollege.replaceAll(':collegeId', '$id')),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Row 1: image + name/university + status ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppBadge(label: status, color: badgeColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (university.isNotEmpty)
                          Text(
                            ' $university جامعة',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey[600]),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  buildCollegeImage(
                      college['imagePath'] ?? college['image'] ?? college['logo']),
                ],
              ),

              SizedBox(height: 10.h),
              const Divider(height: 1, thickness: 0.6),
              SizedBox(height: 10.h),

              // ── Row 2: meta chips ──
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                alignment: WrapAlignment.end,
                children: [
                  if (lastUploadDate.isNotEmpty)
                    MetaChip(
                      icon: Icons.upload_file_outlined,
                      label: lastUploadDate,
                      color: Colors.teal,
                    ),
                  if (institutionType.isNotEmpty)
                    MetaChip(
                      icon: Icons.apartment_outlined,
                      label: institutionType,
                      color: Colors.indigo,
                    ),
                  if (accreditationType.isNotEmpty)
                    MetaChip(
                      icon: Icons.verified_outlined,
                      label: accreditationType,
                      color: Colors.purple,
                    ),
                ],
              ),
              SizedBox(height: 10.h),

              // ── Row 3: readiness progress bar ──
              Row(
                children: [
                  Text(
                    '${readiness.toInt()}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: readinessColor(readiness),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: readiness / 100,
                        minHeight: 7.h,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            readinessColor(readiness)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'نسبة الجاهزية',
                    style:
                        TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
