// lib/features/admin/presentation/screens/employees_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
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

class _EmployeesView extends StatefulWidget {
  const _EmployeesView();

  @override
  State<_EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<_EmployeesView> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموظفون'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
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
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                          width: 45.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r))),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: double.infinity,
                                height: 14.h,
                                color: Colors.white),
                            SizedBox(height: 8.h),
                            Container(
                                width: 120.w,
                                height: 10.h,
                                color: Colors.white),
                            SizedBox(height: 8.h),
                            Container(
                                width: 60.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r))),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle)),
                    ],
                  ),
                ),
              ),
            );
          }

          // ✅ FIX 1: type safety
          List<Map<String, dynamic>> employees = [];
          if (state is EmployeesLoaded) {
            employees =
                state.employees.whereType<Map<String, dynamic>>().toList();
          }

          final filteredEmployees = employees.where((e) {
            final fName = (e['fullName'] ?? '').toString().toLowerCase();
            final email = (e['email'] ?? '').toString().toLowerCase();
            final role = (e['role'] ?? '').toString().toLowerCase();
            final q = _searchQuery.toLowerCase();
            return fName.contains(q) || email.contains(q) || role.contains(q);
          }).toList();

          return RefreshIndicator(
            color: AppColors.cyan,
            backgroundColor: AppColors.navyBlue,
            strokeWidth: 3.0,
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await ctx.read<AdminCubit>().loadEmployees();
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              children: [
                AppTextField(
                  controller: _searchCtrl,
                  label: 'ابحث بالاسم أو البريد الإلكتروني...',
                ),
                SizedBox(height: 16.h),
                if (employees.isEmpty && state is EmployeesLoaded)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('لا يوجد موظفون',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ))
                else if (filteredEmployees.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('لا يوجد موظف مطابق للبحث',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ))
                else
                  ...filteredEmployees.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _buildEmployeeCard(
                            e, context, ctx.read<AdminCubit>()),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.navyBlue,
        label: const Text('إضافة موظف',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeCard(
      Map<String, dynamic> e, BuildContext context, AdminCubit cubit) {
    final id = (e['id'] ?? e['employeeId'] ?? 0) as int;
    final role = (e['role'] ?? e['roleName'] ?? 'موظف').toString();
    final profileImage = (e['profileImage'] ?? '').toString();
    final fullName = (e['fullName'] ?? '').toString().trim();
    final email = (e['email'] ?? '').toString().trim();

    final displayName = fullName.isNotEmpty ? fullName : 'مستخدم رقم $id';
    final secondaryInfo = email.isNotEmpty ? email : 'ID: $id';

    return AppCard(
      padding: EdgeInsets.all(12.w),
      child: Row(children: [
        // أزرار الإجراءات
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showEditDialog(context, e),
              child: Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.blue, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text('تعديل',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: () => _showDeleteConfirm(context, cubit, id, displayName),
              child: Container(
                width: 70.w,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline,
                        color: AppColors.error, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text('حذف',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        // تفاصيل الموظف
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                secondaryInfo,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 6.h),
              AppBadge(
                label: role.isNotEmpty ? role : 'موظف',
                color: AppColors.navyBlue,
                small: true,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        // الصورة الشخصية
        CircleAvatar(
          backgroundColor: AppColors.navyBlue.withOpacity(0.1),
          backgroundImage:
              profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
          radius: 26.r,
          child: profileImage.isNotEmpty
              ? null
              : Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : "م",
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
        ),
      ]),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, AdminCubit cubit, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: Text('هل أنت متأكد من رغبتك في حذف الموظف "$name"؟',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteEmployee(id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = context.read<AdminCubit>();

    // استخراج قائمة الإيميلات المسجلة حالياً
    final currentState = cubit.state;
    final existingEmails = currentState is EmployeesLoaded
        ? currentState.employees
            .map((e) => (e['email'] ?? '').toString().trim().toLowerCase())
            .toList()
        : <String>[];

    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int selectedRoleId = 3; // 3 = موظف الجودة كافتراضي
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
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
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'اسم العائلة',
                  controller: lastCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'البريد الإلكتروني',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'مطلوب';
                    if (!v.contains('@')) return 'بريد غير صحيح';
                    if (existingEmails.contains(v.trim().toLowerCase())) {
                      return 'البريد الإلكتروني مسجل مسبقاً';
                    }
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
                SizedBox(height: 12.h),
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'الصلاحية (الدور)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 1, child: Text('مدير النظام (Admin)')),
                    DropdownMenuItem(
                        value: 2, child: Text('مدير الجودة (Manager)')),
                    DropdownMenuItem(
                        value: 3, child: Text('موظف الجودة (Employee)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedRoleId = val;
                      });
                    }
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
                  'roleId': selectedRoleId, // إرسال الدور المختار
                });
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> employee) {
    final cubit = context.read<AdminCubit>();

    // استخراج الإيميلات لاستبعاد إيميل الموظف الحالي (حتى لا يظهر خطأ إذا لم يغير إيميله)
    final currentState = cubit.state;
    final currentEmail =
        (employee['email'] ?? '').toString().trim().toLowerCase();
    final existingEmails = currentState is EmployeesLoaded
        ? currentState.employees
            .map((e) => (e['email'] ?? '').toString().trim().toLowerCase())
            .where((email) => email.isNotEmpty && email != currentEmail)
            .toList()
        : <String>[];

    final firstCtrl =
        TextEditingController(text: employee['firstName']?.toString() ?? '');
    final lastCtrl =
        TextEditingController(text: employee['lastName']?.toString() ?? '');
    final emailCtrl =
        TextEditingController(text: employee['email']?.toString() ?? '');
    final passCtrl = TextEditingController();

    final roleName = employee['role']?.toString().toLowerCase() ?? '';
    int selectedRoleId = 3; // Default to Employee
    if (roleName.contains('نظام') || roleName.contains('admin'))
      selectedRoleId = 1;
    else if (roleName.contains('مدير') || roleName.contains('manager'))
      selectedRoleId = 2;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: const Text('تعديل بيانات الموظف', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AppTextField(
                  label: 'الاسم الأول',
                  controller: firstCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'اسم العائلة',
                  controller: lastCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'البريد الإلكتروني',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'مطلوب';
                    if (!v.contains('@')) return 'بريد غير صحيح';
                    if (existingEmails.contains(v.trim().toLowerCase())) {
                      return 'البريد الإلكتروني مسجل مسبقاً لموظف آخر';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  label: 'كلمة المرور الجديدة (اختياري)',
                  controller: passCtrl,
                  obscure: true,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'الصلاحية (الدور)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 1, child: Text('مدير النظام (Admin)')),
                    DropdownMenuItem(
                        value: 2, child: Text('مدير الجودة (Manager)')),
                    DropdownMenuItem(
                        value: 3, child: Text('موظف الجودة (Employee)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRoleId = val);
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.navyBlue),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop();
                cubit.updateEmployeeData(
                  employee['id'] as int,
                  {
                    'firstName': firstCtrl.text.trim(),
                    'lastName': lastCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'password': passCtrl.text,
                    'roleId': selectedRoleId,
                  },
                );
              },
              child: const Text('حفظ التعديلات',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
