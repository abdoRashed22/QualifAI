// lib/shared/widgets/app_button.dart

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppButtonVariant { primary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final bool isLoading;

  final bool fullWidth;

  final AppButtonVariant variant;

  final IconData? icon;

  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 52.h;

    Widget child = isLoading
        ? SizedBox(
            width: 22.w,
            height: 22.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.primary
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    final buttonConstraints = BoxConstraints(minWidth: 0, minHeight: h);

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ConstrainedBox(
            constraints: buttonConstraints,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(0, h)),
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
          ),
        );

      case AppButtonVariant.outline:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ConstrainedBox(
            constraints: buttonConstraints,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, h),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
          ),
        );

      case AppButtonVariant.danger:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ConstrainedBox(
            constraints: buttonConstraints,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(0, h),
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
          ),
        );

      case AppButtonVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: ConstrainedBox(
            constraints: buttonConstraints,
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: Size(0, h)),
              onPressed: isLoading ? null : onPressed,
              child: child,
            ),
          ),
        );
    }
  }
}
