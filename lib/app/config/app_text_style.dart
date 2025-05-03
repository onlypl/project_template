import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_template/app/config/app_colors.dart';

/// 此类各种字体样式 fontWeight  fontSize color
/// 尽量先找相同的，在相同参数后面 添加不同的变量
/// PingFang SC-Regular
/// PingFang SC-Semibold
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

///文字主色
TextStyle textMain8 = TextStyle(color: AppColor.textMain, fontSize: 8.sp);
TextStyle textMain8_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textMain,
);
TextStyle textMain11 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textMain,
  fontSize: 11.sp,
);
TextStyle textMain12 = TextStyle(color: AppColor.textMain, fontSize: 12.sp);
TextStyle textMain12Bold = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 12.sp,
);
TextStyle textMain13 = TextStyle(color: AppColor.textMain, fontSize: 13.sp);

TextStyle textMain14 = TextStyle(color: AppColor.textMain, fontSize: 14.sp);
TextStyle textMain14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textMain,
  fontSize: 14.sp,
);
TextStyle textMain14Bold = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 14.sp,
);
TextStyle textMain14_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textMain,
  fontSize: 14.sp,
);
TextStyle textMain16 = TextStyle(color: AppColor.textMain, fontSize: 16.sp);
TextStyle textMain16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textMain,
  fontSize: 16.sp,
);
TextStyle textMain16Bold = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 16.sp,
);
TextStyle textMain16_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textMain,
  fontSize: 16.sp,
);
TextStyle textMain18 = TextStyle(color: AppColor.textMain, fontSize: 18.sp);
TextStyle textMain18_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textMain,
  fontSize: 18.sp,
);
TextStyle textMain18_600 = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 18.sp,
);
TextStyle textMain18_700 = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 18.sp,
);
TextStyle textMain20 = TextStyle(color: AppColor.textMain, fontSize: 20.sp);
TextStyle textMain20_500 = TextStyle(
  color: AppColor.textMain,
  fontWeight: FontWeight.w500,
  fontSize: 20.sp,
);
TextStyle textMain20Bold = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 20.sp,
);
TextStyle textMain20_700 = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 20.sp,
  color: AppColor.textMain,
);
TextStyle textMain22 = TextStyle(color: AppColor.textMain, fontSize: 22.sp);
TextStyle textMain22_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textMain,
  fontSize: 24.sp,
);
TextStyle textMain24 = TextStyle(color: AppColor.textMain, fontSize: 24.sp);
TextStyle textMain24_600 = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 24.sp,
  color: AppColor.textMain,
);
TextStyle textMain28 = TextStyle(color: AppColor.textMain, fontSize: 28.sp);
TextStyle textMain28_600 = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 28.sp,
);
TextStyle textMain32_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textMain,
  fontSize: 32.sp,
);
TextStyle textMain32Bold = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textMain,
  fontSize: 32.sp,
);

///文字次色
TextStyle textSecond12 = TextStyle(color: AppColor.textSecond, fontSize: 12.sp);
TextStyle textSecond12_500 = TextStyle(
  fontSize: 12.sp,
  fontWeight: FontWeight.w500,
  color: AppColor.textSecond,
);
TextStyle textSecond12Bold = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 12.sp,
  color: AppColor.textSecond,
);
TextStyle textSecond14 = TextStyle(color: AppColor.textSecond, fontSize: 14.sp);
TextStyle textSecond14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 14.sp,
  color: AppColor.textSecond,
);
TextStyle textSecond14Normal = TextStyle(
  color: AppColor.textSecond,
  fontSize: 14.sp,
  height: 1.4,
);
TextStyle textSecond14Bold = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 14.sp,
  color: AppColor.textSecond,
);
TextStyle textSecond16 = TextStyle(color: AppColor.textSecond, fontSize: 16.sp);
TextStyle textSecond16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textSecond,
  fontSize: 16.sp,
);
TextStyle textSecond16Bold = TextStyle(
  fontWeight: FontWeight.w600,
  color: AppColor.textSecond,
  fontSize: 16.sp,
);

///文字hint色
TextStyle textThird10 = TextStyle(color: AppColor.textThird, fontSize: 10.sp);
TextStyle textThird12 = TextStyle(color: AppColor.textThird, fontSize: 12.sp);

TextStyle textThird14 = TextStyle(color: AppColor.textThird, fontSize: 14.sp);

TextStyle textThird16 = TextStyle(color: AppColor.textThird, fontSize: 16.sp);
TextStyle textThird16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 16.sp,
);
TextStyle textThird24 = TextStyle(color: AppColor.textThird, fontSize: 24.sp);
TextStyle textThird24_600 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textMain,
  fontSize: 24.sp,
);

///文字灰色
TextStyle textGray10 = TextStyle(color: AppColor.textGray, fontSize: 10.sp);
TextStyle textGray10_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textGray,
  fontSize: 10.sp,
);
TextStyle textGray12 = TextStyle(color: AppColor.textGray, fontSize: 12.sp);
TextStyle textGray14 = TextStyle(color: AppColor.textGray, fontSize: 14.sp);
TextStyle textGray14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 14.sp,
  color: AppColor.textGray,
);
TextStyle textGray16 = TextStyle(color: AppColor.textGray, fontSize: 16.sp);
TextStyle textGray16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textGray,
  fontSize: 16.sp,
);

TextStyle textGraySecond14 = TextStyle(
  color: AppColor.textGray2,
  fontSize: 14.sp,
);

///文字棕色
TextStyle textBrown10 = TextStyle(color: AppColor.textBrown, fontSize: 10.sp);
TextStyle textBrown10_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 10.sp,
  color: AppColor.textBrown,
);
TextStyle textBrown14 = TextStyle(color: AppColor.textBrown, fontSize: 14.sp);
TextStyle textBrown14_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textBrown,
  fontSize: 14.sp,
);
TextStyle textBrown18 = TextStyle(color: AppColor.textBrown, fontSize: 18.sp);
TextStyle textBrown18_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textBrown,
  fontSize: 18.sp,
);

///文字红色
TextStyle textRed12 = TextStyle(color: AppColor.textRed, fontSize: 12.sp);
TextStyle textRed14 = TextStyle(color: AppColor.textRed, fontSize: 14.sp);
TextStyle textRed14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 14.sp,
  color: AppColor.textRed,
);
TextStyle textRed16 = TextStyle(color: AppColor.textRed, fontSize: 16.sp);
TextStyle textRed16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 16.sp,
  color: AppColor.textRed,
);
TextStyle textRed18 = TextStyle(color: AppColor.textRed, fontSize: 18.sp);
TextStyle textRed18_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 18.sp,
  color: AppColor.textRed,
);

///文字白色
TextStyle textWhite12 = TextStyle(color: AppColor.textWhite, fontSize: 12.sp);
TextStyle textWhite12_500 = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 12.sp,
  color: AppColor.textWhite,
);
TextStyle textWhite12_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textWhite,
  fontSize: 12.sp,
);
TextStyle textWhite16 = TextStyle(color: AppColor.textWhite, fontSize: 16.sp);
TextStyle textWhite16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textWhite,
  fontSize: 16.sp,
);
TextStyle textWhiteWith35_16 = TextStyle(
  color: AppColor.textWhite35,
  fontSize: 16.sp,
);
TextStyle textWhiteWith35_16_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textWhite,
  fontSize: 16.sp,
);
TextStyle textWhiteWith75_14 = TextStyle(
  color: AppColor.textWhite75,
  fontSize: 14.sp,
);
TextStyle textWhiteWith75_14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textWhite,
  fontSize: 14.sp,
);
TextStyle textWhiteWith75_14_700 = TextStyle(
  fontWeight: FontWeight.w700,
  color: AppColor.textWhite,
);

///文字蓝色
TextStyle textBlue12 = TextStyle(color: AppColor.textBlue, fontSize: 12.sp);
TextStyle textBlue14 = TextStyle(color: AppColor.textBlue, fontSize: 14.sp);
TextStyle textBlue14_500 = TextStyle(
  fontWeight: FontWeight.w500,
  color: AppColor.textBlue,
  fontSize: 14.sp,
);
