// lib/features/admin/presentation/screens/employees_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('الموظفون'), actions: [
        IconButton(
          icon: const Icon(Icons.person_add_outlined),
          onPressed: () => _showAddDialog(context),
        ),
      ]),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ FIX 1: type safety
          List<Map<String, dynamic>> employees = [];
          if (state is EmployeesLoaded) {
            employees =
                state.employees.whereType<Map<String, dynamic>>().toList();
          }

          if (employees.isEmpty && state is EmployeesLoaded) {
            return const Center(child: Text('لا يوجد موظفون'));
          }

          return RefreshIndicator(
            onRefresh: () => ctx.read<AdminCubit>().loadEmployees(),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: employees.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final e = employees[i];

                // ✅ FIX 2: safe extraction
                final id = e['id'] ?? 0;
                final firstName = e['firstName'] ?? '';
                final lastName = e['lastName'] ?? '';
                final email = e['email'] ?? '';
                final role = e['role'] ?? e['roleName'] ?? 'موظف';
                final profileImage =
                    (e['profileImage'] ?? e['image'] ?? e['photo'] ?? '')
                        .toString();

                final name = '$firstName $lastName'.trim();

                return AppCard(
                  child: Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              ctx.read<AdminCubit>().deleteEmployee(id),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'حذف',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            name,
                            style:
                                Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            email,
                            style:
                                Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 4.h),
                          AppBadge(
                            label: role.isNotEmpty ? role : 'موظف',
                            color: AppColors.blue,
                            small: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    CircleAvatar(
                      backgroundColor: AppColors.blue.withOpacity(0.15),
                      backgroundImage:
                          profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                      radius: 22.r,
                      child: profileImage.isNotEmpty
                          ? null
                          : Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "م",
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue,
                              ),
                            ),
                    ),
                  ]),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.navyBlue,
        label: const Text('إضافة موظف',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('إضافة موظف جديد', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AppTextField(
                label: 'الاسم الأول',
                controller: firstCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'اسم العائلة',
                controller: lastCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'البريد الإلكتروني',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (!v.contains('@')) return 'بريد غير صحيح';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'كلمة المرور',
                controller: passCtrl,
                obscure: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (v.length < 4) return 'كلمة المرور قصيرة';
                  return null;
                },
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              Navigator.of(dialogContext).pop();

              cubit.createEmployee({
                'firstName': firstCtrl.text.trim(),
                'lastName': lastCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'password': passCtrl.text,
                'roleId': 1,
              });
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}