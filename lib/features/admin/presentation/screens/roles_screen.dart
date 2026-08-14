// lib/features/admin/presentation/screens/roles_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/dialogs/app_confirmation_dialog.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

import '../cubit/admin_cubit.dart';
import '../../data/models/role_model.dart';
import '../../data/models/permission_model.dart';
import '../widgets/roles/summary_card.dart';
import '../widgets/roles/roles_role_card.dart';
import '../widgets/roles/roles_permissions_bottom_sheet.dart';
import '../widgets/roles/roles_role_details_bottom_sheet.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadRoles(),
      child: const _RolesView(),
    );
  }
}

class _RolesView extends StatefulWidget {
  const _RolesView();

  @override
  State<_RolesView> createState() => _RolesViewState();
}

class _RolesViewState extends State<_RolesView> {
  List<RoleModel> _cachedRoles = const [];
  List<PermissionModel> _cachedPermissions = const [];
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
        title: const Text('الأدوار والصلاحيات'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => SideRailNavigation.of(context)?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'قائمة الصلاحيات',
            onPressed: () => context.push(AppRoutes.permissions),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (ctx, state) {
          if (state is RolesLoaded) {
            _cachedRoles = state.roles;
            _cachedPermissions = state.permissions;
          }
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            ctx.read<AdminCubit>().loadRoles();
          }
          if (state is AdminError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return ListView.separated(
              padding: AppSpacing.screenPadding(),
              itemCount: 6,
              separatorBuilder: (_, __) => AppSpacing.h10(),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            );
          }

          final rolesState = state is RolesLoaded
              ? state
              : RolesLoaded(_cachedRoles, _cachedPermissions);

          final allRoles = rolesState.roles;
          final filteredRoles = allRoles
              .where((r) =>
                  r.roleName.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          final totalRoles = allRoles.length;
          final totalEmployees =
              allRoles.fold(0, (sum, r) => sum + r.employeesCount);

          if (rolesState.roles.isNotEmpty || state is RolesLoaded) {
            return RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.navyBlue,
              strokeWidth: 3.0,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await ctx.read<AdminCubit>().loadRoles();
              },
              child: ListView(
                padding: AppSpacing.screenPadding(),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'الأدوار النشطة',
                          value: '$totalRoles',
                          icon: Icons.security,
                          color: AppColors.cyan,
                        ),
                      ),
                      AppSpacing.w8(),
                      Expanded(
                        child: SummaryCard(
                          title: 'موظفين مرتبطين',
                          value: '$totalEmployees',
                          icon: Icons.people,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h16(),
                  AppSearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    hintText: 'ابحث عن دور...',
                  ),
                  AppSpacing.h16(),
                  if (filteredRoles.isEmpty)
                    const AppEmptyState(message: 'لا توجد أدوار مطابقة')
                  else
                    ...filteredRoles.map((r) => RolesRoleCard(
                          roleName: r.roleName,
                          roleDesc: r.description,
                          empCount: r.employeesCount,
                          onDelete: () => _confirmDelete(ctx, r.id),
                          onPermissions: () => _showPermissions(
                              ctx, r.id, r.roleName, rolesState.permissions),
                          onDetails: () =>
                              _showDetails(ctx, r.id, r.employeesCount),
                        )),
                ],
              ),
            );
          }

          if (state is AdminError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    AppConfirmationDialog.show(
      context,
      title: 'تأكيد الحذف',
      message: 'هل أنت متأكد من رغبتك في حذف هذا الدور؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
      onConfirm: () => context.read<AdminCubit>().deleteRole(id),
    );
  }

  void _showPermissions(BuildContext context, int roleId, String roleName,
      List<dynamic> allPerms) {
    final cubit = context.read<AdminCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => RolesPermissionsBottomSheet(
        cubit: cubit,
        roleId: roleId,
        roleName: roleName,
        allPerms: allPerms,
      ),
    );
  }

  void _showDetails(BuildContext context, int roleId, int empCount) {
    final cubit = context.read<AdminCubit>();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => RolesRoleDetailsBottomSheet(
        cubit: cubit,
        roleId: roleId,
        empCount: empCount,
      ),
    );
  }
}
