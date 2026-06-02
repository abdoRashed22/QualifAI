import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qualif_ai/features/admin/presentation/screens/support_cubit.dart';
import 'package:qualif_ai/features/admin/presentation/screens/support_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SupportCubit>(),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatefulWidget {
  const _SupportView();

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني', style: TextStyle(fontFamily: 'Cairo')),
        centerTitle: true,
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state is SupportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            _nameCtrl.clear();
            _emailCtrl.clear();
            _msgCtrl.clear();
          } else if (state is SupportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SupportLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                Icon(Icons.support_agent,
                    size: 80.sp, color: AppColors.navyBlue),
                SizedBox(height: 16.h),
                Text(
                  'فريق الدعم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'نحن نقدم دعمًا موثوقًا وحلولًا مخصصة لضمان حل مشكلاتك بسرعة وكفاءة.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'الاسم',
                          controller: _nameCtrl,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'يرجى إدخال الاسم'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: 'البريد الإلكتروني',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'يرجى إدخال البريد الإلكتروني';
                            if (!v.contains('@'))
                              return 'بريد إلكتروني غير صالح';
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        AppTextField(
                          label: 'الرسالة',
                          controller: _msgCtrl,
                          maxLines: 5,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'يرجى إدخال الرسالة أو تفاصيل المشكلة'
                              : null,
                        ),
                        SizedBox(height: 24.h),
                        AppButton(
                          label: 'ارسال',
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<SupportCubit>().submit(
                                    _nameCtrl.text.trim(),
                                    _emailCtrl.text.trim(),
                                    _msgCtrl.text.trim(),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
