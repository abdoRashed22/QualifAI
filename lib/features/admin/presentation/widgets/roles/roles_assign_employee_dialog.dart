import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RolesAssignEmployeeDialog extends StatefulWidget {
  final int roleId;
  const RolesAssignEmployeeDialog({super.key, required this.roleId});

  @override
  State<RolesAssignEmployeeDialog> createState() =>
      _RolesAssignEmployeeDialogState();
}

class _RolesAssignEmployeeDialogState extends State<RolesAssignEmployeeDialog> {
  // Temporary minimal placeholder to keep compilation.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('نقل موظف حالي لهذا الدور', textAlign: TextAlign.right),
      content: const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
