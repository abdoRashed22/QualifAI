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
                  Icon(Icons.workspace_premium_rounded,
                      size: 64.sp, color: AppColors.warning),
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

    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isActive
              ? AppColors.navyBlue
              : theme.dividerColor.withOpacity(0.3),
          width: isActive ? 2.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.navyBlue.withOpacity(0.12)
                : Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isActive)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navyBlue, AppColors.blue],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'الباقة الحالية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.navyBlue.withOpacity(0.1)
                              : theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: isActive
                              ? AppColors.navyBlue
                              : theme.disabledColor,
                          size: 28.sp,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'سنوياً /',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.disabledColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'ر.س',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? AppColors.navyBlue
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          color: isActive
                              ? AppColors.navyBlue
                              : theme.textTheme.titleLarge?.color,
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Divider(color: theme.dividerColor.withOpacity(0.3)),
                  SizedBox(height: 16.h),
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
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.8),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
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
                            isActive ? AppColors.success : AppColors.navyBlue,
                        disabledBackgroundColor:
                            AppColors.success.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: isActive ? 0 : 4,
                        shadowColor: AppColors.navyBlue.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isActive) ...[
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            isActive ? 'أنت مشترك في هذه الباقة' : 'اشترك الآن',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: theme.cardColor,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyBlue, AppColors.blue],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.credit_card_outlined,
                      color: Colors.white, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text('بيانات الدفع',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white)),
                  Text('دفع آمن ومحمي بالكامل',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'الاسم على البطاقة',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _cardCtrl,
                      label: 'رقم البطاقة',
                      icon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (v) =>
                          v!.length != 16 ? 'يجب أن يتكون من 16 رقم' : null,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cvvCtrl,
                            label: 'CVV',
                            icon: Icons.security_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (v) => v!.length < 3 ? 'مطلوب' : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _expiryCtrl,
                            label: 'الانتهاء',
                            hint: 'MM/YY',
                            icon: Icons.date_range_outlined,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: theme.dividerColor.withOpacity(0.5)),
                      ),
                      child: CheckboxListTile(
                        value: _remember,
                        activeColor: AppColors.navyBlue,
                        onChanged: (v) => setState(() => _remember = v ?? true),
                        title: Text('حفظ البطاقة للمرات القادمة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text('إلغاء',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.sp,
                                    color: theme.disabledColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyBlue,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                              elevation: 4,
                              shadowColor: AppColors.navyBlue.withOpacity(0.4),
                            ),
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
                            child: Text('دفع واشتراك',
                                style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(
          fontFamily: 'Cairo', fontSize: 14.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(icon, color: theme.disabledColor, size: 20.sp),
        labelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 13.sp, color: theme.disabledColor),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.navyBlue, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: validator,
    );
  }
}
