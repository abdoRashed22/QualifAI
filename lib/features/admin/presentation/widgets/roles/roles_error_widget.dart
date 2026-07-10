import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class RolesErrorWidget extends StatelessWidget {
  final String message;
  const RolesErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.error,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
