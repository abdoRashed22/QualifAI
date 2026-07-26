// lib/features/admin/presentation/screens/colleges_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

import '../cubit/admin_cubit.dart';
import '../widgets/colleges/college_card.dart';
import '../widgets/colleges/college_shimmer_card.dart';
import '../widgets/colleges/add_college_dialog.dart';

class CollegesScreen extends StatelessWidget {
  const CollegesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadColleges(),
      child: const _CollegesView(),
    );
  }
}

class _CollegesView extends StatelessWidget {
  const _CollegesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكليات'),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddCollegeDialog(context),
        label: const Text('إضافة كلية'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is CollegesLoadedSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return ListView.separated(
              padding: AppSpacing.listPadding(),
              itemCount: 6,
              separatorBuilder: (_, __) => AppSpacing.h10(),
              itemBuilder: (_, __) => const CollegeShimmerCard(),
            );
          }

          if (state is CollegesLoaded || state is CollegesLoadedSuccess) {
            final colleges = state is CollegesLoadedSuccess
                ? state.colleges
                : (state as CollegesLoaded).colleges;
            if (colleges.isEmpty) {
              return const AppEmptyState(
                icon: Icons.account_balance,
                message: 'لا توجد كليات',
              );
            }

            return RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.navyBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await ctx.read<AdminCubit>().loadColleges();
              },
              child: ListView.separated(
                padding: AppSpacing.listPadding(),
                itemCount: colleges.length,
                separatorBuilder: (_, __) => AppSpacing.h10(),
                itemBuilder: (_, i) {
                  final c = colleges[i] as Map<String, dynamic>? ?? {};
                  return CollegeCard(college: c, cubit: ctx.read<AdminCubit>());
                },
              ),
            );
          }

          if (state is AdminError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showAddCollegeDialog(BuildContext context) {
    // TODO: [REFACTOR] Old inline dialog code replaced by AddCollegeDialog
    // Old code had ~150 lines of inline dialog with image picker, form fields, dropdowns
    AddCollegeDialog.show(context, context.read<AdminCubit>());
  }
}

// ── PricingScreen ─────────────────────────────────────────────────────────────
// TODO: [REFACTOR] This screen should be moved to its own file in future refactoring
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<AdminCubit>()..loadPlans(),
        child: const _PricingView());
  }
}

class _PricingView extends StatelessWidget {
  const _PricingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسعار والاشتراكات'),
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
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (ctx, state) {
          if (state is AdminLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is PlansLoaded) {
            if (state.plans.isEmpty)
              return const Center(child: Text('لا توجد باقات'));

            return ListView.separated(
              padding: AppSpacing.listPadding(),
              itemCount: state.plans.length,
              separatorBuilder: (_, __) => AppSpacing.h12(),
              itemBuilder: (_, i) {
                final p = state.plans[i] as Map<String, dynamic>? ?? {};
                final features = (p['features'] as List?) ?? [];
                final isPopular = i == 1;

                return Container(
                  decoration: BoxDecoration(
                    color: isPopular
                        ? AppColors.navyBlue
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: isPopular
                            ? AppColors.navyBlue
                            : Theme.of(context).dividerColor,
                        width: isPopular ? 0 : 0.5),
                  ),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isPopular)
                          Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                  color: AppColors.cyan,
                                  borderRadius: BorderRadius.circular(20.r)),
                              child: Text('الأكثر شيوعاً',
                                  style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: AppColors.navyBlue,
                                      fontWeight: FontWeight.w700))),
                        Text(p['name'] ?? '',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isPopular ? Colors.white : null)),
                        AppSpacing.h4(),
                        Text('£ ${(p['price'] ?? 0).toStringAsFixed(0)}',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: isPopular
                                    ? AppColors.cyan
                                    : AppColors.navyBlue)),
                        Text('/ سنويًا',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: isPopular ? Colors.white60 : null)),
                        AppSpacing.h4(),
                        if ((p['description'] ?? '').toString().isNotEmpty)
                          Text(p['description'].toString(),
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: isPopular
                                      ? Colors.white70
                                      : Theme.of(context).disabledColor),
                              textAlign: TextAlign.right),
                        AppSpacing.h12(),
                        ...features.map((f) {
                          final fStr = f.toString();
                          if (fStr == 'string' || fStr.isEmpty)
                            return const SizedBox.shrink();

                          return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(fStr,
                                        style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12.sp,
                                            color: isPopular
                                                ? Colors.white70
                                                : null)),
                                    AppSpacing.w6(),
                                    Icon(Icons.check_circle_outline,
                                        size: 14.sp,
                                        color: isPopular
                                            ? AppColors.cyan
                                            : AppColors.success),
                                  ]));
                        }),
                      ]),
                );
              },
            );
          }

          if (state is AdminError) return Center(child: Text(state.message));

          return const SizedBox();
        },
      ),
    );
  }
}
