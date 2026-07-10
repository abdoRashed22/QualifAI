import 'package:flutter/material.dart';

class RolesEmptyWidget extends StatelessWidget {
  final String message;
  const RolesEmptyWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}
