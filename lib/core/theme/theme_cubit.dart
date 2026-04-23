// lib/core/theme/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/hive_cache.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final HiveCache _cache;

  ThemeCubit(this._cache)
      : super(_cache.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    _cache.setDarkMode(!isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
