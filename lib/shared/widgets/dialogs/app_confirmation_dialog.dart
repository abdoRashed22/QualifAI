// lib/shared/widgets/dialogs/app_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';

/// Replaces inline delete/confirm dialogs across the app
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.confirmColor,
    this.cancelColor,
    this.icon,
    this.onCancel,
  });

  /// Show the dialog and return true if confirmed
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: title,
        message: message,
        onConfirm: () {
          Navigator.of(ctx).pop();
          onConfirm();
        },
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    ).then((_) => false);
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (icon != null) ...[
            Center(
              child: Icon(
                icon,
                size: 48.sp,
                color: confirmColor ?? AppColors.error,
              ),
            ),
            AppSpacing.h16(),
          ],
          Text(
            message,
            textAlign: TextAlign.right,
            style: AppTypography.bodyMedium(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop();
          },
          child: Text(
            cancelText,
            style: AppTypography.bodyMedium(color: cancelColor ?? AppColors.subTextLight),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
