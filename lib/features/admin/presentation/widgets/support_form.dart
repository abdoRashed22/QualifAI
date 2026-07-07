import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qualif_ai/features/admin/presentation/cubit/support_cubit.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';

class SupportForm extends StatelessWidget {
  const SupportForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'الاسم',
              controller: nameCtrl,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'يرجى إدخال الاسم' : null,
            ),
            SizedBox(height: 16.h),
            AppTextField(
              label: 'البريد الإلكتروني',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!v.contains('@')) return 'بريد إلكتروني غير صالح';
                return null;
              },
            ),
            SizedBox(height: 16.h),
            AppTextField(
              label: 'الرسالة',
              controller: msgCtrl,
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
                if (formKey.currentState?.validate() ?? false) {
                  context.read<SupportCubit>().submit(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        msgCtrl.text.trim(),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
