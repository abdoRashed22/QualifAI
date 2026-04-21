// lib/features/auth/presentation/screens/forgot_password_screen.dart
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
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
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
            if (state is ForgotPasswordSuccess) {
              showDialog(
                context: ctx,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ðŸ”', style: TextStyle(fontSize: 48.sp)),
                      SizedBox(height: 16.h),
                      Text(
                        'ØªÙ… Ø¥Ø±Ø³Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±\nØ¥Ù„Ù‰ Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
                        textAlign: TextAlign.center,
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ctx.go(AppRoutes.login);
                        },
                        child: const Text('ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          builder: (ctx, state) {
            final cubit = ctx.read<AuthCubit>();
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ðŸ”', style: TextStyle(fontSize: 54.sp)),
                        SizedBox(height: 16.h),
                        Text(
                          'Ø§Ø³ØªØ¹Ø§Ø¯Ø© ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Ø£Ø¯Ø®Ù„ Ø¨ÙŠØ§Ù†Ø§ØªÙƒ Ù„Ø¥Ø±Ø³Ø§Ù„ ÙƒÙˆØ¯ Ø§Ù„ØªØ­Ù‚Ù‚',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
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
                              label: 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ',
                              hint: 'user@email.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Ù…Ø·Ù„ÙˆØ¨';
                                if (!v.contains('@')) return 'Ø¨Ø±ÙŠØ¯ Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ ØºÙŠØ± ØµØ­ÙŠØ­';
                                return null;
                              },
                            ),
                            SizedBox(height: 32.h),
                            AppButton(
                              label: 'Ø¥Ø±Ø³Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±',
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  cubit.forgotPassword(_emailCtrl.text.trim());
                                }
                              },
                            ),
                            SizedBox(height: 20.h),
                            Center(
                              child: TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                child: Text(
                                  'â† Ø§Ù„Ø¹ÙˆØ¯Ø© Ù„ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    color: AppColors.blue,
                                  ),
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
