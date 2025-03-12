//颜色类
//主色调
import 'dart:math';

import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(0xfffb7299, <int, Color>{
  50: Color(0xffff9db5),
});

const MaterialColor white = MaterialColor(0xFFFFFFFF, <int, Color>{
  50: Color(0xFFFFFFFF),
  100: Color(0xFFFFFFFF),
  200: Color(0xFFFFFFFF),
  300: Color(0xFFFFFFFF),
  400: Color(0xFFFFFFFF),
  500: Color(0xFFFFFFFF),
  600: Color(0xFFFFFFFF),
  700: Color(0xFFFFFFFF),
  800: Color(0xFFFFFFFF),
  900: Color(0xFFFFFFFF),
});

class AppColor {
  static const Color themeColor = Color(0xFF00ADB5);
  static const Color themeColor2 = Color(0xFFDDF5F6);
  static const Color primaryColor = Color(0xFFFFFFFF);
  static const Color darkPrimaryColor = Color(0xFF161616); //161616 25272A
  //161616
  ///页面背景
  static const Color pageBg = Color(0xFFFDFDFD);
  static const Color darkPageBg = Color(0xFF101010);
  static const Color pageBg2 = Color(0xFFF1F1F1);
  static const Color darkPageBg2 = Color(0xFF1D1D1D);
  //#161D28
  ///2B2D30
  //导航栏
  static const Color navBarBgColor = Color(0xFFFFFFFF);
  static const Color darkNavBarBgColor = Color(0xFF161616);

  ///121212 212223

  static const Color colorD3 = Color(0xFFD3D3D3);
  static const Color colorF1 = Color(0xFFF1F1F1);
  static const Color colorF3 = Color(0xFFF3F3F3);

  ///文字颜色
  static const Color black = Color(0xFF000000);
  static const Color darkBlack = Color(0xFFFFFFFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color darkWhite = Color(0xFF000000);

  static const Color textColor222 = Color(0xFF222222);
  static const Color textColor333 = Color(0xFF333333);
  static const Color textColor444 = Color(0xFF444444);
  static const Color textColor666 = Color(0xFF666666);
  static const Color darkTextColor666 = Color(0xFF999999);
  static const Color textColor777 = Color(0xFF777777);
  static const Color textColor999 = Color(0xFF999999);

  //底部tab背景色
  static const Color tabBarBgColor = themeColor;
  static const Color darkTabBarBgColor = Color(0xFF161616);

  //底部tabItem颜色
  static const Color tabBarItemColor = AppColor.white;
  static const Color tabBarUnItemColor = AppColor.colorF1;

  static const Color darkTabBarItemColor = AppColor.white;
  static const Color darkTabBarUnItemColor = AppColor.colorF1;

  //Card背景色
  static const Color cardBgColor = AppColor.white;
  static const Color darkCardBgColor = Color(0xFF121212);

  ///分割线颜色
  static const Color dividerColor = Color(0xFFEFEFEF);
  static const Color darkDividerColor = Color(0xFF1D1D1D);

  static const Color divider2Color = Color(0xFFF3F3F3);
  static const Color darkDivider2Color = Color(0xFFF3F3F3);

  // 渐变色（appBar和按钮）
  static const Color gradientStartColor = Color(0xFF2683BE); // 渐变开始色
  static const Color gradientEndColor = Color(0xFF34CABE); // 渐变结束色

  //根据主题设置颜色
  Color getThemeColor(isDarkMode, darkColor, lightColor) {
    return isDarkMode ? darkColor : lightColor;
  }

  ///随机色
  Color randomColor() {
    return Color.fromARGB(
      255, // 不透明度（0到255）
      Random().nextInt(255), // 红色（0到255）
      Random().nextInt(255), // 绿色（0到255）
      Random().nextInt(255), // 蓝色（0到255）
    );
  }
}

Color hexColor(String hexString) {
  String hex = hexString.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // 默认透明度为1（FF）
  } else if (hex.length == 3) {
    hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}'; // 简写形式
  }
  return Color(int.parse(hex, radix: 16));
}
