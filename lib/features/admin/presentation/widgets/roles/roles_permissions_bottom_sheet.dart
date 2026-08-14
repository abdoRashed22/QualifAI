// lib/features/admin/presentation/widgets/roles/roles_permissions_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../data/models/permission_model.dart';
import '../../cubit/admin_cubit.dart';

class RolesPermissionsBottomSheet extends StatefulWidget {
  final AdminCubit cubit;
  final int roleId;
  final String roleName;
  final List<dynamic> allPerms;
  const RolesPermissionsBottomSheet({
    super.key,
    required this.cubit,
    required this.roleId,
    required this.roleName,
    required this.allPerms,
  });

  @override
  State<RolesPermissionsBottomSheet> createState() =>
      _RolesPermissionsBottomSheetState();
}

class _RolesPermissionsBottomSheetState
    extends State<RolesPermissionsBottomSheet> {
  final List<int> _selectedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await widget.cubit.fetchRolePermissions(widget.roleId);
    if (!mounted) return;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(ids);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.w,
        right: 16.w,
        top: 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'صلاحيات ${widget.roleName}',
            style: AppTypography.titleMedium(),
          ),
          AppSpacing.h16(),
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.allPerms.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'لا توجد صلاحيات متاحة في النظام',
                  style: AppTypography.bodyMedium(),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allPerms.length,
                itemBuilder: (ctx, i) {
                  final p = widget.allPerms[i] is PermissionModel
                      ? widget.allPerms[i] as PermissionModel
                      : PermissionModel(
                          id: i + 1,
                          name: 'صلاحية ${i + 1}',
                          description: 'لا يوجد وصف متوفر لهذه الصلاحية',
                        );
                  final pId = p.id;
                  final pName = p.name;
                  final isSelected = _selectedIds.contains(pId);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          if (!_selectedIds.contains(pId)) {
                            _selectedIds.add(pId);
                          }
                        } else {
                          _selectedIds.remove(pId);
                        }
                      });
                    },
                    title: Text(
                      pName,
                      style: AppTypography.bodyMedium(),
                      textAlign: TextAlign.right,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.cyan,
                    checkColor: AppColors.navyBlue,
                  );
                },
              ),
            ),
          AppSpacing.h16(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      widget.cubit
                          .assignRolePermissions(widget.roleId, _selectedIds);
                      Navigator.pop(context);
                    },
              child: Text(
                'حفظ التغييرات',
                style: AppTypography.buttonText(color: Colors.white),
              ),
            ),
          ),
          AppSpacing.h24(),
        ],
      ),
    );
  }
}
