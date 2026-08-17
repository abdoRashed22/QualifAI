import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../data/remote/pricing_remote_ds.dart';
import '../../data/repository/pricing_repository_impl.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../cubit/pricing_cubit.dart';
import '../cubit/pricing_state.dart';
import '../widgets/pricing_plan_card.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PricingCubit(
        PricingRepositoryImpl(
          PricingRemoteDs(sl<Dio>()),
        ),
      )..loadPlans(),
      child: const _PricingView(),
    );
  }
}

class _PricingView extends StatelessWidget {
  const _PricingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاسعار', style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // keep existing navigation behaviour by leaving this open to be wired later
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocConsumer<PricingCubit, PricingState>(
        listener: (context, state) {
          if (state is PricingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PricingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PricingLoading || state is PricingSubscribeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PricingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<PricingCubit>().loadPlans(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PricingLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 64.sp,
                    color: AppColors.warning,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'باقات الاشتراكات - QualifAI',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'ارتقِ بجودة مؤسستك التعليمية مع باقاتنا المتميزة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  ...state.plans.map((plan) {
                    if (plan.name == 'string') {
                      return const SizedBox.shrink();
                    }

                    return PricingPlanCard(
                      plan: plan,
                      isActive: plan.isActive || plan.isCurrentPlan,
                      onSubscribe: (data) {
                        context.read<PricingCubit>().subscribe(data);
                      },
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
