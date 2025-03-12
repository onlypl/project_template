import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';

import 'ar_AR/ar_ar_translation.dart';
import 'en_US/en_us_translation.dart';
import 'zh_CN/zh_cn_translation.dart';

//国际化服务类
class LocalizationService extends Translations {
  // prevent creating instance
  LocalizationService._();

  static LocalizationService? _instance;

  static LocalizationService getInstance() {
    _instance ??= LocalizationService._();
    return _instance!;
  }

  // default language
  // todo change the default language
  static Locale defaultLanguage = supportedLanguages['zh']!;

  // supported languages
  static Map<String, Locale> supportedLanguages = {
    'zh': const Locale('zh', 'ZH'),
    'en': const Locale('en', 'US'),
    'ar': const Locale('ar', 'AR'),
  };

  // supported languages fonts family (must be in assets & pubspec yaml) or you can use google fonts
  static Map<String, TextStyle> supportedLanguagesFontsFamilies = {
    // todo add your English font families (add to assets/fonts, pubspec and name it here) default is poppins for english and cairo for arabic
    'zh': const TextStyle(fontFamily: 'Poppins'),
    'en': const TextStyle(fontFamily: 'Poppins'),
    'ar': const TextStyle(fontFamily: 'Cairo'),
  };

  //获取语言包
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': zhCn,
    'en_US': enUs,
    'ar_AR': arAR,
  };

  /// 检查是否支持该语言
  static isLanguageSupported(String languageCode) =>
      supportedLanguages.keys.contains(languageCode);

  /// 修改当前语言
  static updateLanguage(String languageCode) async {
    // 检查是否支持该语言
    if (!isLanguageSupported(languageCode)) return;
    // 更新持久话当前语言
    await AppSharedPreferences.setCurrentLanguage(languageCode);
    if (!Get.testMode) {
      Get.updateLocale(supportedLanguages[languageCode]!);
    }
  }

  //当前是否是英语
  static bool isItEnglish() => AppSharedPreferences.getCurrentLocal()
      .languageCode
      .toLowerCase()
      .contains('en');
  //当前是否是中文
  static bool isItChinese() => AppSharedPreferences.getCurrentLocal()
      .languageCode
      .toLowerCase()
      .contains('cn');

  ///获取当前语言
  static Locale getCurrentLocal() => AppSharedPreferences.getCurrentLocal();
}
