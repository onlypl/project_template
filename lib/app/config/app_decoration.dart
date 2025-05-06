import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppDecoration {
  ///背景
  static BoxDecoration bgWhite60_12 = BoxDecoration(
    color: AppColor.bgWhite60,
    borderRadius: BorderRadius.circular(12.h),
  );
  static BoxDecoration bgWhite_10 = BoxDecoration(
    color: AppColor.bgWhite,
    borderRadius: BorderRadius.circular(10.h),
  );

  static BoxDecoration bgWhite_8 = BoxDecoration(
    color: AppColor.bgWhite,
    borderRadius: BorderRadius.circular(8.h),
  );

  static BoxDecoration bgPink_6 = BoxDecoration(
    color: AppColor.bgPink,
    borderRadius: BorderRadius.circular(6.h),
  );
  static BoxDecoration bgPink_7 = BoxDecoration(
    color: AppColor.bgPink2,
    borderRadius: BorderRadius.circular(6.h),
  );

  static BoxDecoration bgGreenLight_6 = BoxDecoration(
    color: AppColor.bgGreenLight,
    borderRadius: BorderRadius.circular(6.h),
  );

  static BoxDecoration bgGreenLight_7 = BoxDecoration(
    color: AppColor.bgGreenLight2,
    borderRadius: BorderRadius.circular(6.h),
  );

  static BoxDecoration bgGray_2 = BoxDecoration(
    color: AppColor.bgGray,
    borderRadius: BorderRadius.circular(2.h),
  );

  static BoxDecoration bgGray_6 = BoxDecoration(
    color: AppColor.bgGray,
    borderRadius: BorderRadius.circular(6.h),
  );

  static BoxDecoration bgGray(double radius) {
    return BoxDecoration(
      color: AppColor.bgGray,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgGray2(double radius) {
    return BoxDecoration(
      color: AppColor.bgGray2,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgWhite(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgWhite95(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite95,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgWhite95WhitShadows(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite95,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [BoxShadow(blurRadius: 80)],
    );
  }

  static BoxDecoration bgBlue(double radius) {
    return BoxDecoration(
      color: AppColor.bgBlue,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgGrayTop(double radius) {
    return BoxDecoration(
      color: AppColor.bgGray,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
    );
  }

  static BoxDecoration bgWhiteTop(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
    );
  }

  static BoxDecoration bgLineBlue(double radius) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColor.lineBlue, width: 1.h),
    );
  }

  static BoxDecoration bgBlackTrans(double radius) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: AppColor.bgBlack.withAlpha(34),
    );
  }

  static BoxDecoration bgRedLightWithLineRed(double radius) {
    return BoxDecoration(
      color: AppColor.bgRedLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColor.lineRed, width: 1.h),
    );
  }

  static BoxDecoration bgLineBlue_4 = BoxDecoration(
    color: AppColor.bgWhite,
    border: Border.all(color: AppColor.lineBlue, width: 1.h),
    borderRadius: BorderRadius.circular(4.h),
  );

  static BoxDecoration bgLineBlue_6 = BoxDecoration(
    color: AppColor.bgWhite,
    border: Border.all(color: AppColor.lineBlue, width: 1.h),
    borderRadius: BorderRadius.circular(6.h),
  );

  static BoxDecoration bgLineGray2(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite,
      border: Border.all(color: AppColor.lineGray2, width: 1.h),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgGrayLineGray2(double radius) {
    return BoxDecoration(
      color: AppColor.bgGray,
      border: Border.all(color: AppColor.lineGray2, width: 1.h),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration bgLineGray(double radius) {
    return BoxDecoration(
      color: AppColor.bgWhite,
      border: Border.all(color: AppColor.lineGray, width: 1.h),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  ///背景渐变
  static BoxDecoration bgWhitePinkBorder_6 = BoxDecoration(
    borderRadius: BorderRadius.circular(6.h),
    gradient: LinearGradient(colors: [AppColor.bgWhite, AppColor.bgPinkLight]),
    border: Border.all(color: AppColor.linePink, width: 1.h),
  );
  static BoxDecoration bgWhiteYellowBorder_6 = BoxDecoration(
    borderRadius: BorderRadius.circular(6.h),
    gradient: LinearGradient(
      colors: [AppColor.bgWhite, AppColor.bgYellowLight],
    ),
    border: Border.all(color: AppColor.lineYellow, width: 1.h),
  );
  static BoxDecoration bgBlueGradient4 = BoxDecoration(
    borderRadius: BorderRadius.circular(4.h),
    gradient: LinearGradient(
      colors: [AppColor.gradientBlueStart, AppColor.gradientBlueEnd],
    ),
  );
  static BoxDecoration bgGrayGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColor.bgGray.withAlpha(0), AppColor.bgGray],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  ///横线
  static BoxDecoration lineRed = BoxDecoration(
    color: AppColor.lineRed,
    borderRadius: BorderRadius.circular(1.h),
  );
}
