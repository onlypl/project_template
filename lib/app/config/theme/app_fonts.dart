import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';

import '../translations/localization_service.dart';

// todo configure text family and size
class AppFonts {
  // return the right font depending on app language
  static TextStyle get getAppFontType =>
      LocalizationService
          .supportedLanguagesFontsFamilies[AppSharedPreferences.getCurrentLocal()
          .languageCode]!;

  // headlines text font
  static TextStyle get headlineTextStyle => getAppFontType;

  // body text font
  static TextStyle get bodyTextStyle => getAppFontType;

  // button text font
  static TextStyle get buttonTextStyle => getAppFontType;

  // app bar text font
  static TextStyle get appBarTextStyle => getAppFontType;

  // chips text font
  static TextStyle get chipTextStyle => getAppFontType;

  // appbar font size
  static double get appBarTittleSize => 18.sp;

  // body font size
  static double get body1TextSize => 12.sp;
  static double get body2TextSize => 14.sp;

  // headlines font size
  static double get headline1TextSize => 50.sp;
  static double get headline2TextSize => 40.sp;
  static double get headline3TextSize => 30.sp;
  static double get headline4TextSize => 25.sp;
  static double get headline5TextSize => 20.sp;
  static double get headline6TextSize => 16.sp;

  //button font size
  static double get buttonTextSize => 16.sp;

  //caption font size
  static double get captionTextSize => 13.sp;

  //chip font size
  static double get chipTextSize => 10.sp;
}
