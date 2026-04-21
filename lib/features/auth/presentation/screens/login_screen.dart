// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
            if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is AuthSuccess) {
              final role = state.user.role;
              if (role == 'system_admin') {
                ctx.go(AppRoutes.adminDashboard);
              } else {
                ctx.go(AppRoutes.dashboard);
              }
            }
          },
          builder: (ctx, state) {
            final cubit = ctx.read<AuthCubit>();
            return Column(
              children: [
                // â”€â”€ Top section (navy) â”€â”€
                Expanded(
                  flex: 4,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'ðŸ¤–',
                              style: TextStyle(fontSize: 44.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Welcome to QualifAI',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Ø³Ø¬Ù‘Ù„ Ø¯Ø®ÙˆÙ„Ùƒ Ù„Ù„Ù…ØªØ§Ø¨Ø¹Ø©',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // â”€â”€ Bottom card â”€â”€
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppTextField(
                              label: 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… / Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
                              hint: 'user@email.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _passFocus.requestFocus(),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Ù…Ø·Ù„ÙˆØ¨';
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            AppTextField(
                              label: 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
                              controller: _passCtrl,
                              obscure: true,
                              focusNode: _passFocus,
                              prefixIcon: Icons.lock_outline,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _onLogin(cubit),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Ù…Ø·Ù„ÙˆØ¨';
                                if (v.length < 4) return 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ù‚ØµÙŠØ±Ø© Ø¬Ø¯Ø§Ù‹';
                                return null;
                              },
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.forgotPassword),
                              child: Text(
                                'Ù†Ø³ÙŠØª ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±ØŸ',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            AppButton(
                              label: 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„',
                              isLoading: state is AuthLoading,
                              onPressed: () => _onLogin(cubit),
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: Text(
                                'v1.0.0  â€¢  QualifAI',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.sp,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
