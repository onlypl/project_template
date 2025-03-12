import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_template/app/config/app_colors.dart';

class AppTextStyle {
  // final BuildContext context;
  // AppTextStyle(this.context);

  static TextStyle get title => TextStyle(
    color: AppColor.textColor333,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get subTitle => TextStyle(
    color: AppColor.textColor333,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get bodyText => TextStyle(
    color: AppColor.textColor333,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle get bodyTextSmall => TextStyle(
    color: AppColor.textColor333,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get buttonText =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700);
  static TextStyle get hintText => TextStyle(
    color: AppColor.textColor333,
    fontSize: 21.sp,
    fontWeight: FontWeight.w300,
  );
  static TextStyle get appBarText => TextStyle(
    color: AppColor.textColor333,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  );
}
