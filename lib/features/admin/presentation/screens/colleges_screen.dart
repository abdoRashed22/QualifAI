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

