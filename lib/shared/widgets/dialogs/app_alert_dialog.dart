// lib/shared/widgets/dialogs/app_alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

/// Replaces inline generic AlertDialog patterns
class AppAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppAlertDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
      ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: AppTypography.titleMedium(),
      ),
      content: Text(
        message,
        textAlign: TextAlign.right,
        style: AppTypography.bodyMedium(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('حسناً'),
        ),
        if (actionLabel != null && onAction != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction!();
            },
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
