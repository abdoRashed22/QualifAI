// lib/shared/widgets/cards/app_list_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../app_card.dart';

/// Replaces generic card patterns for list items across the app
class AppListCard extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppListCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.onTap,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? AppSpacing.all12(),
      onTap: onTap,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (trailing != null) ...[
                trailing!,
                AppSpacing.w8(),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (title != null) title!,
                    if (subtitle != null) ...[
                      AppSpacing.h4(),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (leading != null) ...[
                AppSpacing.w10(),
                leading!,
              ],
            ],
          ),
          if (bottom != null) ...[
            AppSpacing.h12(),
            const Divider(height: 1, thickness: 0.5),
            AppSpacing.h10(),
            bottom!,
          ],
        ],
      ),
    );
  }
}
