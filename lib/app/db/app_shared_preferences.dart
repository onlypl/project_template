import 'dart:convert';
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

  static const String _domainPool = 'domain_pool';
  static const String _currentDomain = "current_domain";

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // static setStorage(SharedPreferences sharedPreferences) {
  //   _sharedPreferences = sharedPreferences;
  // }

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

  ///保存域名池
  static Future<void> setDomainPool(List<String> pool) =>
      _sharedPreferences.setStringList(_domainPool, pool);

  /// 获取域名池
  static List<String>? getDomainPool() =>
      _sharedPreferences.getStringList(_domainPool);

  ///设置当前域名
  static Future<void> setCurrentDomain(String domain) =>
      _sharedPreferences.setString(_currentDomain, domain);

  /// 获取当前域名
  static String? getCurrentDomain() =>
      _sharedPreferences.getString(_currentDomain);

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

  /// 设置存储
  static Future<void> setStorage(String key, dynamic value) async {
    // await init();
    String type;
    // 监测value的类型 如果是Map和List,则转换成JSON，以字符串进行存储
    if (value is Map || value is List) {
      type = 'String';
      value = const JsonEncoder().convert(value);
    }
    // 否则 获取value的类型的字符串形式
    else {
      type = value.runtimeType.toString();
    }
    // 根据value不同的类型 用不同的方法进行存储
    switch (type) {
      case 'String':
        await _sharedPreferences.setString(key, value);
        break;
      case 'int':
        await _sharedPreferences.setInt(key, value);
        break;
      case 'double':
        await _sharedPreferences.setDouble(key, value);
        break;
      case 'bool':
        await _sharedPreferences.setBool(key, value);
        break;
    }
  }

  /// 删除key指向的存储 如果key存在则删除并返回true，否则返回false
  static Future<bool> removeStorage(String key) async {
    if (await hasKey(key)) {
      await _sharedPreferences.remove(key);
      return true;
    } else {
      return false;
    }
    // return  _storage.remove(key);
  }

  /// 获取存储 注意：返回的是一个Future对象 要么用await接收 要么在.then中接收
  static Future<T?> get<T>(String key) async {
    var result = _sharedPreferences.get(key);
    if (result != null) {
      return result as T;
    }
    return null;
  }

  /// 是否包含某个key
  static Future<bool> hasKey(String key) async {
    return _sharedPreferences.containsKey(key);
  }

  /// 获取所有的key 类型为Set<String>
  static Future<Set<String>> getKeys() async {
    return _sharedPreferences.getKeys();
  }

  // 判断是否是JSON字符串
  _isJson(dynamic value) {
    try {
      // 如果value是一个json的字符串 则不会报错 返回true
      const JsonDecoder().convert(value);
      return true;
    } catch (e) {
      // 如果value不是json的字符串 则报错 进入catch 返回false
      return false;
    }
  }
}
