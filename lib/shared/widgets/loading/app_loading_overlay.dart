// lib/shared/widgets/loading/app_loading_overlay.dart
import 'package:flutter/material.dart';

/// Replaces inline LoadingOverlay pattern from app_card.dart
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? barrierColor;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: barrierColor ?? Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
