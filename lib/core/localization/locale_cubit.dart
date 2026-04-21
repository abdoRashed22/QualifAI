// lib/core/localization/locale_cubit.dart

import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/hive_cache.dart';

class LocaleCubit extends Cubit<Locale> {
  final HiveCache _cache;

  LocaleCubit(this._cache)
      : super(Locale(_cache.getLanguage()));

  void changeLocale(String langCode) {
    _cache.setLanguage(langCode);
    emit(Locale(langCode));
  }

  bool get isArabic => state.languageCode == 'ar';

  void toggleLocale() {
    changeLocale(isArabic ? 'en' : 'ar');
  }
}
