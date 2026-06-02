import 'package:flutter/material.dart';

class NavRailItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavRailItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
