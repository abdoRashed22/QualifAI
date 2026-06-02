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

import '../../../../shared/widgets/app_card.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../../../profile/data/remote/side_rail_navigation.dart';

import '../cubit/admin_cubit.dart';

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
  List<dynamic> _cachedRoles = const [];
  List<dynamic> _cachedPermissions = const [];
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
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddRoleDialog(context),
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
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success));
            // تحديث قائمة الأدوار لضمان تحديث عداد الموظفين بعد الإضافة
            ctx.read<AdminCubit>().loadRoles();
          }

          if (state is AdminError)
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
        },
        builder: (ctx, state) {
          if (state is AdminLoading)
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor.withOpacity(0.5),
                child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r))),
              ),
            );

          final rolesState = state is RolesLoaded
              ? state
              : RolesLoaded(_cachedRoles, _cachedPermissions);

          final allRoles = rolesState.roles;
          final filteredRoles = allRoles.where((r) {
            final name =
                (r['roleName'] ?? r['name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          final totalRoles = allRoles.length;
          final totalEmployees = allRoles.fold(
              0,
              (sum, r) =>
                  sum + (int.tryParse('${r['employeesCount'] ?? 0}') ?? 0));

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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryCard(
                              title: 'الأدوار النشطة',
                              value: '$totalRoles',
                              icon: Icons.security,
                              color: AppColors.cyan)),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: _SummaryCard(
                              title: 'موظفين مرتبطين',
                              value: '$totalEmployees',
                              icon: Icons.people,
                              color: AppColors.blue)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _searchCtrl,
                    label: 'ابحث عن دور...',
                  ),
                  SizedBox(height: 16.h),
                  if (filteredRoles.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('لا توجد أدوار مطابقة',
                                style: TextStyle(fontFamily: 'Cairo'))))
                  else
                    ...filteredRoles.map(
                        (r) => _buildRoleCard(r, ctx, rolesState.permissions)),
                ],
              ),
            );
          }

          if (state is AdminError) return Center(child: Text(state.message));

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRoleCard(
      Map<String, dynamic> r, BuildContext context, List<dynamic> allPerms) {
    final roleId = int.tryParse('${r['id'] ?? r['roleId'] ?? 0}') ?? 0;
    final roleName = r['roleName'] ?? r['name'] ?? 'دور';
    final roleDesc = r['description'] ?? r['roleDescription'] ?? 'لا يوجد وصف';
    final empCount = r['employeesCount'] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AppCard(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDelete(context, roleId),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(roleName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text(roleDesc,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          textAlign: TextAlign.right),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.adminColor.withOpacity(0.12),
                  child: Icon(Icons.security, color: AppColors.adminColor),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _InfoChip(
                    icon: Icons.people_alt_outlined,
                    label: '$empCount موظف',
                    color: AppColors.blue),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPermissionsBottomSheet(
                        context, roleId, roleName, allPerms),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.navyBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: const Text('الصلاحيات',
                        style: TextStyle(
                            fontFamily: 'Cairo', color: AppColors.navyBlue)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDetailsBottomSheet(context, roleId, empCount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: const Text('التفاصيل',
                        style: TextStyle(
                            fontFamily: 'Cairo', color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الدور؟',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().deleteRole(id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, int roleId, dynamic empCount) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>?>(
        future: context.read<AdminCubit>().fetchRoleDetails(roleId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator()));
          final data = snapshot.data ?? {};
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data['roleName'] ?? 'تفاصيل الدور',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(data['roleDescription'] ?? 'لا يوجد وصف',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp)),
                SizedBox(height: 16.h),

                _InfoChip(
                    icon: Icons.people_alt_outlined,
                    label: 'عدد الموظفين: $empCount',
                    color: AppColors.blue),
                    
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.navyBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEmployeeToRoleDialog(context, roleId);
                    },
                    icon: const Icon(Icons.person_add_alt_1, color: AppColors.navyBlue),
                    label: const Text('تعيين موظف جديد لهذا الدور',
                        style: TextStyle(color: AppColors.navyBlue, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAssignExistingEmployeeDialog(context, roleId);
                    },
                    icon: const Icon(Icons.manage_accounts, color: AppColors.blue),
                    label: const Text('تعديل دور موظف حالي لهذا الدور',
                        style: TextStyle(color: AppColors.blue, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إغلاق',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Cairo')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPermissionsBottomSheet(BuildContext context, int roleId,
      String roleName, List<dynamic> allPerms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => _PermissionsBottomSheet(
        roleId: roleId,
        roleName: roleName,
        allPerms: allPerms,
        cubit: context.read<AdminCubit>(),
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final cubit = context.read<AdminCubit>();

    final nameCtrl = TextEditingController();

    final descCtrl = TextEditingController();

    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r)),
              title: const Text('إنشاء دور جديد', textAlign: TextAlign.right),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                AppTextField(label: 'اسم الدور', controller: nameCtrl),
                SizedBox(height: 12.h),
                AppTextField(
                    label: 'وصف الدور', controller: descCtrl, maxLines: 2),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('إلغاء')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      cubit.createRole(
                          nameCtrl.text.trim(), descCtrl.text.trim());
                    },
                    child: const Text("إنشاء")),
              ],
            ));
  }

  void _showAddEmployeeToRoleDialog(BuildContext context, int roleId) {
    final cubit = context.read<AdminCubit>();
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('تعيين موظف جديد', textAlign: TextAlign.right),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBlue),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop();
              cubit.createEmployee({
                'firstName': firstCtrl.text.trim(),
                'lastName': lastCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'password': passCtrl.text,
                'roleId': roleId, // تمرير معرف الدور مباشرة
              });
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAssignExistingEmployeeDialog(BuildContext context, int roleId) {
    final cubit = context.read<AdminCubit>();
    final future = cubit.fetchEmployeesList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        Map<String, dynamic>? selectedEmployee;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                title: const Text('نقل موظف حالي لهذا الدور', textAlign: TextAlign.right),
                content: const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              );
            }
            
            final employees = snapshot.data ?? [];
            if (employees.isEmpty) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                title: const Text('نقل موظف حالي لهذا الدور', textAlign: TextAlign.right),
                content: const Text('لا يوجد موظفون حالياً في النظام', textAlign: TextAlign.right),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق'))
                ],
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  title: const Text('نقل موظف حالي لهذا الدور', textAlign: TextAlign.right),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'اختر الموظف',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          isExpanded: true,
                          items: employees.map((emp) {
                            final String fName = (emp['fullName']?.toString().trim() ?? '');
                            final String emailStr = (emp['email']?.toString() ?? '');
                            final String display = fName.isNotEmpty ? fName : (emailStr.isNotEmpty ? emailStr : 'مستخدم ${emp['id']}');
                            
                            return DropdownMenuItem(
                              value: emp,
                              child: Text('$display (${emp['role']})', textAlign: TextAlign.right),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedEmployee = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBlue),
                      onPressed: selectedEmployee == null
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                              cubit.updateEmployeeData(
                                selectedEmployee!['id'] as int,
                                {
                                  'firstName': selectedEmployee!['firstName'],
                                  'lastName': selectedEmployee!['lastName'],
                                  'email': selectedEmployee!['email'],
                                  'roleId': roleId,
                                },
                              );
                            },
                      child: const Text('تأكيد النقل', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: color),
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: color)),
          SizedBox(height: 4.h),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}


class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PermissionsBottomSheet extends StatefulWidget {
  final int roleId;
  final String roleName;
  final List<dynamic> allPerms;
  final AdminCubit cubit;

  const _PermissionsBottomSheet(
      {required this.roleId,
      required this.roleName,
      required this.allPerms,
      required this.cubit});

  @override
  State<_PermissionsBottomSheet> createState() =>
      _PermissionsBottomSheetState();
}

class _PermissionsBottomSheetState extends State<_PermissionsBottomSheet> {
  List<int> _selectedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await widget.cubit.fetchRolePermissions(widget.roleId);
    if (mounted) {
      setState(() {
        _selectedIds = ids;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('صلاحيات ${widget.roleName}',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          if (_isLoading)
            const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator()))
          else if (widget.allPerms.isEmpty)
            const SizedBox(
                height: 100,
                child: Center(
                    child: Text('لا توجد صلاحيات متاحة في النظام',
                        style: TextStyle(fontFamily: 'Cairo'))))
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allPerms.length,
                itemBuilder: (ctx, i) {
                  final p = widget.allPerms[i] as Map<String, dynamic>;
                  final pId =
                      int.tryParse('${p['id'] ?? p['permissionId']}') ?? 0;
                  final pName =
                      p['name'] ?? p['permissionName'] ?? 'صلاحية $pId';
                  final isSelected = _selectedIds.contains(pId);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true)
                          _selectedIds.add(pId);
                        else
                          _selectedIds.remove(pId);
                      });
                    },
                    title: Text(pName,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                        textAlign: TextAlign.right),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.cyan,
                    checkColor: AppColors.navyBlue,
                  );
                },
              ),
            ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h)),
              onPressed: _isLoading
                  ? null
                  : () {
                      widget.cubit
                          .assignRolePermissions(widget.roleId, _selectedIds);
                      Navigator.pop(context);
                    },
              child: const Text('حفظ التغييرات',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
