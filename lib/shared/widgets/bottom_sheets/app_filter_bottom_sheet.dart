// lib/shared/widgets/bottom_sheets/app_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Reusable filter bottom sheet that replaces inline filter sheets
class AppFilterBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onApply;
  final VoidCallback? onReset;
  final String applyText;
  final String resetText;

  const AppFilterBottomSheet({
    super.key,
    required this.title,
    required this.children,
    this.onApply,
    this.onReset,
    this.applyText = 'تطبيق',
    this.resetText = 'إعادة تعيين',
  });

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    VoidCallback? onApply,
    VoidCallback? onReset,
    String applyText = 'تطبيق',
    String resetText = 'إعادة تعيين',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24.r),
        ),
      ),
      builder: (ctx) => AppFilterBottomSheet(
        title: title,
        children: children,
        onApply: onApply,
        onReset: onReset,
        applyText: applyText,
        resetText: resetText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: AppSpacing.only(top: 12, bottom: 8),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(AppRadius.rFull.r),
                ),
              ),
            ),
            // Title & Reset
            Padding(
              padding: AppSpacing.horizontal16(),
              child: Row(
                children: [
                  if (onReset != null)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReset!();
                      },
                      child: Text(resetText),
                    ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTypography.titleMedium(),
                  ),
                ],
              ),
            ),
            AppSpacing.h16(),
            // Content
            ...children,
            AppSpacing.h24(),
            // Apply button
            Padding(
              padding: AppSpacing.horizontal16(),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onApply?.call();
                },
                child: Text(applyText),
              ),
            ),
            AppSpacing.h32(),
          ],
        ),
      ),
    );
  }
}
