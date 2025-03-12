import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';

class MyStyles {
  ///icons theme
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color:
            isLightTheme
                ? LightThemeColors.iconColor
                : DarkThemeColors.iconColor,
      );

  ///app bar theme
  static AppBarTheme getAppBarTheme({required bool isLightTheme}) =>
      AppBarTheme(
        elevation: 0,
        titleTextStyle: getTextTheme(isLightTheme: isLightTheme).bodyLarge!
            .copyWith(color: Colors.white, fontSize: AppFonts.appBarTittleSize),
        iconTheme: IconThemeData(
          color:
              isLightTheme
                  ? LightThemeColors.appBarIconsColor
                  : DarkThemeColors.appBarIconsColor,
        ),
        backgroundColor:
            isLightTheme
                ? LightThemeColors.appBarColor
                : DarkThemeColors.appbarColor,
      );

  ///text theme
  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
    labelLarge: AppFonts.buttonTextStyle.copyWith(
      fontSize: AppFonts.buttonTextSize,
    ),
    bodyLarge: (AppFonts.bodyTextStyle).copyWith(
      fontWeight: FontWeight.bold,
      fontSize: AppFonts.body1TextSize,
      color:
          isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
    ),
    bodyMedium: (AppFonts.bodyTextStyle).copyWith(
      fontSize: AppFonts.body2TextSize,
      color:
          isLightTheme
              ? LightThemeColors.bodyTextColor
              : DarkThemeColors.bodyTextColor,
    ),
    displayLarge: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline1TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    displayMedium: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline2TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    displaySmall: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline3TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    headlineMedium: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline4TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    headlineSmall: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline5TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    titleLarge: (AppFonts.headlineTextStyle).copyWith(
      fontSize: AppFonts.headline6TextSize,
      fontWeight: FontWeight.bold,
      color:
          isLightTheme
              ? LightThemeColors.headlinesTextColor
              : DarkThemeColors.headlinesTextColor,
    ),
    bodySmall: TextStyle(
      color:
          isLightTheme
              ? LightThemeColors.captionTextColor
              : DarkThemeColors.captionTextColor,
      fontSize: AppFonts.captionTextSize,
    ),
  );

  static ChipThemeData getChipTheme({required bool isLightTheme}) {
    return ChipThemeData(
      backgroundColor:
          isLightTheme
              ? LightThemeColors.chipBackground
              : DarkThemeColors.chipBackground,
      brightness: Brightness.light,
      labelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      secondaryLabelStyle: getChipTextStyle(isLightTheme: isLightTheme),
      selectedColor: Colors.black,
      disabledColor: Colors.green,
      padding: const EdgeInsets.all(5),
      secondarySelectedColor: Colors.purple,
    );
  }

  ///Chips text style
  static TextStyle getChipTextStyle({required bool isLightTheme}) {
    return AppFonts.chipTextStyle.copyWith(
      fontSize: AppFonts.chipTextSize,
      color:
          isLightTheme
              ? LightThemeColors.chipTextColor
              : DarkThemeColors.chipTextColor,
    );
  }

  ///Chips text style
  static Color getContainerColor({required bool isLightTheme}) {
    return isLightTheme
        ? LightThemeColors.backgroundColor
        : DarkThemeColors.backgroundColor;
  }

  static Color getScaffoldColor({required bool isLightTheme}) {
    return isLightTheme
        ? LightThemeColors.scaffoldBackgroundColor
        : DarkThemeColors.scaffoldBackgroundColor;
  }

  static Color getPrimaryColor({required bool isLightTheme}) {
    return isLightTheme
        ? LightThemeColors.primaryColor
        : DarkThemeColors.primaryColor;
  }

  static Color getSecondaryColor({required bool isLightTheme}) {
    return isLightTheme
        ? LightThemeColors.cardColor
        : DarkThemeColors.cardColor;
  }

  static Color getSubtitleColor({required bool isLightTheme}) {
    return isLightTheme
        ? LightThemeColors.iconColor
        : DarkThemeColors.iconColor;
  }

  // elevated button text style
  static MaterialStateProperty<TextStyle?>? getElevatedButtonTextStyle(
    bool isLightTheme, {
    bool isBold = true,
    double? fontSize,
  }) {
    return MaterialStateProperty.resolveWith<TextStyle>((
      Set<MaterialState> states,
    ) {
      if (states.contains(MaterialState.pressed)) {
        return AppFonts.buttonTextStyle.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize ?? AppFonts.buttonTextSize,
          color:
              isLightTheme
                  ? LightThemeColors.buttonTextColor
                  : DarkThemeColors.buttonTextColor,
        );
      } else if (states.contains(MaterialState.disabled)) {
        return AppFonts.buttonTextStyle.copyWith(
          fontSize: fontSize ?? AppFonts.buttonTextSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color:
              isLightTheme
                  ? LightThemeColors.buttonDisabledTextColor
                  : DarkThemeColors.buttonDisabledTextColor,
        );
      }
      return AppFonts.buttonTextStyle.copyWith(
        fontSize: fontSize ?? AppFonts.buttonTextSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color:
            isLightTheme
                ? LightThemeColors.buttonTextColor
                : DarkThemeColors.buttonTextColor,
      ); // Use the component's default.
    });
  }

  //elevated button theme data
  static ElevatedButtonThemeData getElevatedButtonTheme({
    required bool isLightTheme,
  }) => ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
          //side: BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
      elevation: MaterialStateProperty.all(0),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 14.h),
      ),
      textStyle: getElevatedButtonTextStyle(isLightTheme),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((
        Set<MaterialState> states,
      ) {
        if (states.contains(MaterialState.pressed)) {
          return isLightTheme
              ? LightThemeColors.buttonColor.withOpacity(0.5)
              : DarkThemeColors.buttonColor.withOpacity(0.5);
        } else if (states.contains(MaterialState.disabled)) {
          return isLightTheme
              ? LightThemeColors.buttonDisabledColor
              : DarkThemeColors.buttonDisabledColor;
        }
        return isLightTheme
            ? LightThemeColors.buttonColor
            : DarkThemeColors.buttonColor; // Use the component's default.
      }),
    ),
  );
}
