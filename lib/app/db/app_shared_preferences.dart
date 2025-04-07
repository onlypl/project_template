import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/translations/localization_service.dart';

//持久化管理类
//跨平台支持
class AppSharedPreferences {
  // prevent making instance
  AppSharedPreferences._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  // STORING KEYS
  static const String _appTokenKey = 'app_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// 设置当前主题类型是否为light
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// 获取当前主题类型是否为light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ??
      !Get.isDarkMode; // todo set the default theme (true for light, false for dark)

  /// 保存语言
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// 获取当前语言
  static Locale getCurrentLocal() {
    String? langCode = _sharedPreferences.getString(_currentLocalKey);
    // 返回默认语言
    if (langCode == null) {
      return LocalizationService.defaultLanguage;
    }
    return LocalizationService.supportedLanguages[langCode]!;
  }

  /// 保存生成的令牌
  static Future<void> setAppToken(String token) =>
      _sharedPreferences.setString(_appTokenKey, token);

  /// 获取生成的令牌
  static String? getAppToken() =>
      _sharedPreferences.getString(_refreshTokenKey);

  /// 保存生成的刷新令牌
  static Future<void> setRefreshToken(String token) =>
      _sharedPreferences.setString(_refreshTokenKey, token);

  /// 获取生成的刷新令牌
  static String? getRefreshToken() =>
      _sharedPreferences.getString(_appTokenKey);

  /// 清除持久化所有数据
  static Future<void> clear() async => await _sharedPreferences.clear();

  static Future<void> setData(String data, String key) =>
      _sharedPreferences.setString(key, data);
  static String? getData(String key) => _sharedPreferences.getString(key);

  static Future<void> setString(String key, String value) async {
    _sharedPreferences.setString(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    _sharedPreferences.setDouble(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    _sharedPreferences.setInt(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    _sharedPreferences.setBool(key, value);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    _sharedPreferences.setStringList(key, value);
  }

  static Future<T?> get<T>(String key) async {
    var result = _sharedPreferences.get(key);
    if (result != null) {
      return result as T;
    }
    return null;
  }
}
