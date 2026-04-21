// lib/core/cache/hive_cache.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveCache {
  static const String _authBox = 'auth_box';
  static const String _settingsBox = 'settings_box';

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';
  static const String _themeKey = 'is_dark_mode';
  static const String _langKey = 'language_code';

  late final Box _auth;
  late final Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _auth = await Hive.openBox(_authBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // â”€â”€ Token â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> saveToken(String token) async {
    await _auth.put(_tokenKey, token);
  }

  String? getToken() => _auth.get(_tokenKey);

  bool get isLoggedIn => getToken() != null;

  // â”€â”€ User data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _auth.put(_userKey, data);
  }

  Map<dynamic, dynamic>? getUserData() => _auth.get(_userKey);

  Future<void> saveRole(String role) async {
    await _auth.put(_roleKey, role);
  }

  String? getRole() => _auth.get(_roleKey);

  // â”€â”€ Settings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> setDarkMode(bool isDark) async {
    await _settings.put(_themeKey, isDark);
  }

  bool isDarkMode() => _settings.get(_themeKey, defaultValue: false);

  Future<void> setLanguage(String code) async {
    await _settings.put(_langKey, code);
  }

  String getLanguage() => _settings.get(_langKey, defaultValue: 'ar');

  // â”€â”€ Clear â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> clearAll() async {
    await _auth.clear();
  }
}
