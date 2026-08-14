import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../../../shared/widgets/loading/app_shimmer_list.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/employees/employee_card.dart';
import '../dialogs/add_employee_dialog.dart';
import '../dialogs/edit_employee_dialog.dart';

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
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return const AppShimmerList(
              itemCount: 6,
            );
          }

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
              padding: AppSpacing.screenPadding(),
              children: [
                AppSearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  hintText: 'ابحث بالاسم أو البريد الإلكتروني...',
                ),
                AppSpacing.h16(),
                if (employees.isEmpty && state is EmployeesLoaded)
                  const AppEmptyState(message: 'لا يوجد موظفون')
                else if (filteredEmployees.isEmpty)
                  const AppEmptyState(message: 'لا يوجد موظف مطابق للبحث')
                else
                  ...filteredEmployees.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: EmployeeCard(
                          employee: e,
                          onEdit: () => _showEditDialog(ctx, e),
                          onDelete: () => _showDeleteConfirm(ctx, e),
                        ),
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

  void _showDeleteConfirm(BuildContext context, Map<String, dynamic> e) {
    final cubit = context.read<AdminCubit>();
    final id = (e['id'] ?? e['employeeId'] ?? 0) as int;
    final name = (e['fullName'] ?? '').toString().trim();
    final displayName = name.isNotEmpty ? name : 'مستخدم رقم $id';

    AppConfirmationDialog.show(
      context,
      title: 'تأكيد الحذف',
      message: 'هل أنت متأكد من رغبتك في حذف الموظف "$displayName"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
      onConfirm: () => cubit.deleteEmployee(id),
    );
  }

  void _showAddDialog(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final currentState = cubit.state;
    final existingEmails = currentState is EmployeesLoaded
        ? currentState.employees
            .map((e) => (e['email'] ?? '').toString().trim().toLowerCase())
            .toList()
        : <String>[];

    showDialog(
      context: context,
      builder: (_) => AddEmployeeDialog(
        cubit: cubit,
        existingEmails: existingEmails,
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> employee) {
    final cubit = context.read<AdminCubit>();
    final currentState = cubit.state;
    final currentEmail =
        (employee['email'] ?? '').toString().trim().toLowerCase();
    final existingEmails = currentState is EmployeesLoaded
        ? currentState.employees
            .map((e) => (e['email'] ?? '').toString().trim().toLowerCase())
            .where((email) => email.isNotEmpty && email != currentEmail)
            .toList()
        : <String>[];

    showDialog(
      context: context,
      builder: (_) => EditEmployeeDialog(
        cubit: cubit,
        employee: employee,
        existingEmails: existingEmails,
      ),
    );
  }
}
