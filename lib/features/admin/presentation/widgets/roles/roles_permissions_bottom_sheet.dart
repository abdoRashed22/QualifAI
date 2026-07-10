import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../cubit/admin_cubit.dart';

class RolesPermissionsBottomSheet extends StatefulWidget {
  final int roleId;
  final String roleName;
  final List<dynamic> allPerms;
  const RolesPermissionsBottomSheet(
      {super.key,
      required this.roleId,
      required this.roleName,
      required this.allPerms});

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
    final cubit = context.read<AdminCubit>();
    final ids = await cubit.fetchRolePermissions(widget.roleId);
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
    final cubit = context.read<AdminCubit>();

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
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLoading)
            const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator()))
          else if (widget.allPerms.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: Text('لا توجد صلاحيات متاحة في النظام',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            )
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
                        if (val == true) {
                          if (!_selectedIds.contains(pId))
                            _selectedIds.add(pId);
                        } else {
                          _selectedIds.remove(pId);
                        }
                      });
                    },
                    title: Text(
                      pName,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                      textAlign: TextAlign.right,
                    ),
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      cubit.assignRolePermissions(widget.roleId, _selectedIds);
                      Navigator.pop(context);
                    },
              child: const Text(
                'حفظ التغييرات',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
