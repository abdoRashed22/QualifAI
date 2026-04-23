// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';

import '../../../../core/router/app_router.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../shared/widgets/app_button.dart';

import '../../../../shared/widgets/app_text_field.dart';

import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();

  final _passCtrl = TextEditingController();

  final _passFocus = FocusNode();

  bool _navigated = false; // prevent double navigation

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();

    super.dispose();
  }

  void _onLogin(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    cubit.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.navyBlue,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (ctx, state) {
            if (state is AuthSuccess && !_navigated) {
              _navigated = true;

              context.go(AppRoutes.adminDashboard); // غيرها حسب اسم الروت عندك
            }

            if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (ctx, state) {
            final cubit = ctx.read<AuthCubit>();

            return SafeArea(
                child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: IntrinsicHeight(
                            child: Column(
                          children: [
                            // Top navy section
                            Expanded(
                              flex: 4,
                              child: SafeArea(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 90.w,
                                        height: 90.w,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            shape: BoxShape.circle),
                                        // تم استبدال الـ Text بالصورة هنا 👇
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/2 51.png',
                                            fit: BoxFit.cover,
                                            // معالجة الخطأ في حال لم يجد المسار
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.person,
                                                        size: 44.sp,
                                                        color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text('Welcome to QualifAI',
                                          style: GoogleFonts.cairo(
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                      SizedBox(height: 6.h),
                                      Text("سجّل دخولك للمتابعة",
                                          style: GoogleFonts.cairo(
                                              fontSize: 14.sp,
                                              color: Colors.white60)),
                                    ]),
                              ),
                            ),

                            // White card

                            Expanded(
                              flex: 7,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(32.r),
                                      topRight: Radius.circular(32.r)),
                                ),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(
                                      24.w, 32.h, 24.w, 24.h),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          AppTextField(
                                            label:
                                                'اسم المستخدم / البريد الإلكتروني',
                                            hint: 'user@email.com',
                                            controller: _emailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            prefixIcon: Icons.person_outline,
                                            textInputAction:
                                                TextInputAction.next,
                                            onSubmitted: (_) =>
                                                _passFocus.requestFocus(),
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'مطلوب'
                                                    : null,
                                          ),
                                          SizedBox(height: 20.h),
                                          AppTextField(
                                            label: 'كلمة المرور',
                                            controller: _passCtrl,
                                            obscure: true,
                                            focusNode: _passFocus,
                                            prefixIcon: Icons.lock_outline,
                                            textInputAction:
                                                TextInputAction.done,
                                            onSubmitted: (_) => _onLogin(cubit),
                                            validator: (v) {
                                              if (v == null || v.isEmpty)
                                                return 'مطلوب';

                                              if (v.length < 4)
                                                return 'كلمة المرور قصيرة';

                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 12.h),
                                          GestureDetector(
                                            onTap: () => context
                                                .push(AppRoutes.forgotPassword),
                                            child: Text("نسيت كلمة المرور؟",
                                                style: GoogleFonts.cairo(
                                                    fontSize: 13.sp,
                                                    color: AppColors.blue,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          SizedBox(height: 32.h),
                                          AppButton(
                                              label: 'تسجيل الدخول',
                                              isLoading: state is AuthLoading,
                                              onPressed: () => _onLogin(cubit)),
                                          SizedBox(height: 16.h),
                                          Center(
                                              child: Text('v1.0.0  •  QualifAI',
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 11.sp,
                                                      color: Theme.of(context)
                                                          .disabledColor))),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )))));
          },
        ),
      ),
    );
  }
}
