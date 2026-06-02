import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qualif_ai/core/permissions/pricing_cubit.dart';
import 'package:qualif_ai/core/permissions/pricing_remote_ds.dart';
import 'package:qualif_ai/core/permissions/pricing_repository_impl.dart';
import 'package:qualif_ai/core/permissions/pricing_state.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../../features/profile/data/remote/side_rail_navigation.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Bypassing injection configuration edits dynamically by building our required dependencies directly.
      create: (_) => PricingCubit(
        PricingRepositoryImpl(PricingRemoteDs(sl<Dio>())),
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
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
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
                  backgroundColor: AppColors.success),
            );
          } else if (state is PricingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
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
                  Text(state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<PricingCubit>().loadPlans(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue),
                    child: const Text('إعادة المحاولة',
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          if (state is PricingLoaded) {
            final plans = state.plans;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'باقات الاشتراكات - QualifAI',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'فتح إمكانيات لا نهاية لها',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  ...plans.map((planMap) {
                    final plan = planMap as Map<String, dynamic>;

                    // إخفاء الباقات الوهمية القادمة من الـ API
                    if (plan['name'] == 'string') {
                      return const SizedBox.shrink();
                    }

                    final subscriptions = plan['subscriptions'] as List?;
                    final isActive =
                        subscriptions != null && subscriptions.isNotEmpty;

                    return _PlanCard(
                      plan: plan,
                      isActive: isActive,
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

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isActive;

  const _PlanCard({
    required this.plan,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final name = plan['name']?.toString() ?? '';
    final price = plan['price']?.toString() ?? '0';
    final description = plan['description']?.toString() ?? '';

    final rawFeatures = plan['features'];
    List<String> features = [];
    if (rawFeatures is List) {
      features = rawFeatures
          .map((e) => e.toString())
          .where((f) => f.trim().isNotEmpty && f != 'string')
          .toList();
    } else if (rawFeatures is String) {
      features = rawFeatures
          .split('\n')
          .where((f) => f.trim().isNotEmpty && f != 'string')
          .toList();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Text(
                'خطتك الحالية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'ر.س',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      price,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                SizedBox(height: 24.h),
                ...features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isActive
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) =>
                                  _PaymentDialog(onSubmit: (data) {
                                Navigator.pop(dialogCtx); // إغلاق النافذة
                                context.read<PricingCubit>().subscribe(data);
                              }),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                      disabledBackgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                      disabledForegroundColor: Colors.white,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isActive ? 'خطتك الحالية' : 'اشترك الآن',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;

  const _PaymentDialog({required this.onSubmit});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardCtrl.dispose();
    _cvvCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إدخال بيانات الدفع',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textAlign: TextAlign.right,
                decoration:
                    const InputDecoration(labelText: 'الاسم على البطاقة'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _cardCtrl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                    labelText: 'رقم البطاقة', counterText: ''),
                validator: (v) =>
                    v!.length != 16 ? 'يجب أن يتكون من 16 رقم' : null,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                          labelText: 'CVV', counterText: ''),
                      validator: (v) => v!.length < 3 ? 'مطلوب' : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryCtrl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                          labelText: 'تاريخ الانتهاء (MM/YY)',
                          hintText: '12/25'),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              CheckboxListTile(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? true),
                title: const Text('حفظ البطاقة للمرات القادمة',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBlue),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit({
                "cardHolderName": _nameCtrl.text.trim(),
                "cardNumber": _cardCtrl.text.trim(),
                "cvv": _cvvCtrl.text.trim(),
                "expiryDate": _expiryCtrl.text.trim(),
                "rememberCardInfo": _remember,
              });
            }
          },
          child: const Text('دفع واشتراك',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        ),
      ],
    );
  }
}
