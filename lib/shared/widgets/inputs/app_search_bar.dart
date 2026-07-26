// lib/shared/widgets/inputs/app_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Replaces inline search fields across the app
class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.onClear,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'بحث...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  widget.onClear?.call();
                },
              )
            : null,
        contentPadding: AppSpacing.inputPadding(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r12.r),
        ),
      ),
    );
  }
}
