import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../presentation/cubit/reviewer_cubit.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

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
          // ── Loading shimmer ──
          if (state is ReviewerLoading) {
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
                  _shimmerCard(120.h),
                  SizedBox(height: 12.h),
                  _shimmerCard(120.h),
                  SizedBox(height: 12.h),
                  _shimmerCard(120.h),
                ],
              ),
            );
          }

          // ── Error ──
          if (state is ReviewerError) {
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
                    onPressed: () =>
                        context.read<ReviewerCubit>().loadDashboard(),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // ── Loaded ──
          if (state is ReviewerDashboardLoaded) {
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
                              child: _StatInfo(
                                label: 'الكليات المكلفة',
                                value: '${state.totalAssigned}',
                                color: Colors.blue,
                                icon: Icons.school_outlined,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _StatInfo(
                                label: 'قيد المراجعة',
                                value: '${state.pendingReviews}',
                                color: Colors.orange,
                                icon: Icons.hourglass_top_outlined,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _StatInfo(
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
                      final id =
                          _intValue(college['id'] ?? college['collegeId']);
                      final name = _stringValue(college['name'] ??
                          college['collegeName'] ??
                          college['college']);
                      final university =
                          _stringValue(college['university'] ?? '');
                      final institutionType =
                          _stringValue(college['institutionType'] ?? '');
                      final accreditationType = _stringValue(
                          college['accreditationType'] ??
                              college['type'] ??
                              '');
                      final readiness = (college['readinessPercentage'] as num?)
                              ?.toDouble() ??
                          0.0;
                      final status = _statusLabel(college);
                      final badgeColor = _statusColor(status);
                      final lastUploadDate =
                          _formatDate(college['lastUploadDate']);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: AppCard(
                          borderRadius: 16,
                          onTap: () => context.go(AppRoutes.reviewerCollege
                              .replaceAll(':collegeId', '$id')),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                            textAlign: TextAlign.right,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (university.isNotEmpty)
                                            Text(
                                              'جامعة $university',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey[600]),
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    _buildCollegeImage(college['imagePath'] ??
                                        college['image'] ??
                                        college['logo']),
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
                                      _MetaChip(
                                        icon: Icons.upload_file_outlined,
                                        label: lastUploadDate,
                                        color: Colors.teal,
                                      ),
                                    if (institutionType.isNotEmpty)
                                      _MetaChip(
                                        icon: Icons.apartment_outlined,
                                        label: institutionType,
                                        color: Colors.indigo,
                                      ),
                                    if (accreditationType.isNotEmpty)
                                      _MetaChip(
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
                                        color: _readinessColor(readiness),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: LinearProgressIndicator(
                                          value: readiness / 100,
                                          minHeight: 7.h,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  _readinessColor(readiness)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'نسبة الجاهزية',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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
                      final id = _intValue(
                          item['id'] ?? item['collegeId'] ?? item['sectionId']);
                      final title = _stringValue(
                          item['name'] ?? item['collegeName'] ?? item['title']);
                      final subtitle =
                          _stringValue(item['status'] ?? item['reviewStatus']);
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _shimmerCard(double height) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      );

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int _intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  String _statusLabel(dynamic college) {
    final raw = college is Map
        ? college['status'] ?? college['reviewStatus'] ?? college['statusName']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('approve') ||
        value.contains('موافق') ||
        value.contains('معتمد')) {
      return 'معتمد';
    }
    if (value.contains('reject') ||
        value.contains('رفض') ||
        value.contains('مرفوض')) {
      return 'مرفوض';
    }
    if (value.contains('revision') || value.contains('تعديل')) {
      return 'يحتاج تعديل';
    }
    if (value.contains('تسجيل') || value.contains('register')) {
      return 'قيد التسجيل';
    }
    return 'قيد المراجعة';
  }

  Color _statusColor(String status) {
    if (status == 'معتمد') return Colors.green;
    if (status == 'مرفوض') return Colors.red;
    if (status == 'يحتاج تعديل') return Colors.orange;
    if (status == 'قيد التسجيل') return Colors.blueGrey;
    return Colors.blue;
  }

  Color _readinessColor(double value) {
    if (value >= 70) return Colors.green;
    if (value >= 40) return Colors.orange;
    return Colors.redAccent;
  }

  Widget _buildCollegeImage(dynamic imagePath) {
    final url = _resolveImagePath(imagePath);
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: url.isEmpty
            ? Center(
                child: Icon(
                  Icons.account_balance,
                  size: 26.sp,
                  color: Colors.grey[600],
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.account_balance,
                    size: 26.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
      ),
    );
  }

  String _resolveImagePath(dynamic imagePath) {
    if (imagePath == null) return '';
    final path = imagePath.toString().trim();
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) {
      return 'https://qualifai.runasp.net$path';
    }
    return path;
  }
}

// ── _StatInfo ──────────────────────────────────────────────

class _StatInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatInfo({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 11.sp, color: color),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 4.w),
              Icon(icon, size: 13.sp, color: color),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── _MetaChip ──────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: color)),
          SizedBox(width: 4.w),
          Icon(icon, size: 12.sp, color: color),
        ],
      ),
    );
  }
}
