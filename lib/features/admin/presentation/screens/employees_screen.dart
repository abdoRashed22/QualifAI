// lib/features/admin/presentation/screens/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadEmployees(),
      child: const _EmployeesView(),
    );
  }
}

class _EmployeesView extends StatelessWidget {
  const _EmployeesView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ø§Ù„Ù…ÙˆØ¸ÙÙˆÙ†'), actions: [
        IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () => _showAddDialog(context)),
      ]),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.success));
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is EmployeesLoaded) {
            if (state.employees.isEmpty) return const Center(child: Text('Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ù…ÙˆØ¸ÙÙˆÙ†'));
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: state.employees.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final e = state.employees[i] as Map<String, dynamic>? ?? {};
                final name = '${e['firstName'] ?? ''} ${e['lastName'] ?? ''}';
                final role = e['roleName'] ?? e['role'] ?? '';
                return AppCard(
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      GestureDetector(
                        onTap: () => ctx.read<AdminCubit>().deleteEmployee(e['id'] ?? 0),
                        child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8.r)),
                          child: Text('Ø­Ø°Ù', style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white))),
                      ),
                    ]),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(name.trim(), style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
                      SizedBox(height: 4.h),
                      Text(e['email'] ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
                      SizedBox(height: 4.h),
                      AppBadge(label: role.isNotEmpty ? role : 'Ù…ÙˆØ¸Ù', color: AppColors.blue, small: true),
                    ])),
                    SizedBox(width: 10.w),
                    CircleAvatar(backgroundColor: AppColors.blue.withOpacity(0.15), radius: 22.r,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'Ù…',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.blue))),
                  ]),
                );
              },
            );
          }
          if (state is AdminError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.navyBlue,
        label: const Text('Ø¥Ø¶Ø§ÙØ© Ù…ÙˆØ¸Ù', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('Ø¥Ø¶Ø§ÙØ© Ù…ÙˆØ¸Ù Ø¬Ø¯ÙŠØ¯', textAlign: TextAlign.right),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppTextField(label: 'Ø§Ù„Ø§Ø³Ù… Ø§Ù„Ø£ÙˆÙ„', controller: firstCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'Ø§Ø³Ù… Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©', controller: lastCtrl),
        SizedBox(height: 12.h),
        AppTextField(label: 'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
        SizedBox(height: 12.h),
        AppTextField(label: 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±', controller: passCtrl, obscure: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ø¥Ù„ØºØ§Ø¡')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AdminCubit>().createEmployee({
              'firstName': firstCtrl.text, 'lastName': lastCtrl.text,
              'email': emailCtrl.text, 'password': passCtrl.text, 'roleId': 1,
            });
          },
          child: const Text('Ø¥Ø¶Ø§ÙØ©'),
        ),
      ],
    ));
  }
}
