import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'underline_indicator.dart';

class TvTab extends StatelessWidget {
  final List<Widget> tabs;
  final TabController? controller;
  final double? fontSize;
  final double? unselectedFontSize;
  final FontWeight? fontWeight;
  final FontWeight? unselectdFontWeight;
  final double boderWidth;
  final double insets;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color dividerColor;
  final Color borderSideColor;
  final TabAlignment tabAlignment;
  final Decoration? indicator; //自定义指示器 insets则无效
  final EdgeInsets? labelPadding;
  final ValueChanged<int>? onTap;
  const TvTab({
    super.key,
    required this.tabs,
    this.controller,
    this.fontSize = 16,
    this.unselectedFontSize = 16,
    this.boderWidth = 0,
    this.insets = 0,
    this.unselectedLabelColor,
    this.labelColor,
    this.tabAlignment = TabAlignment.start,
    this.dividerColor = Colors.transparent,
    this.borderSideColor = Colors.transparent,
    this.fontWeight,
    this.unselectdFontWeight,
    this.indicator,
    this.labelPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      onTap: onTap,
      labelPadding: labelPadding ?? EdgeInsets.only(left: 5.w, right: 5.w),
      //     indicatorPadding: EdgeInsets.zero,
      controller: controller,
      tabAlignment: tabAlignment,
      isScrollable: true,
      labelColor: labelColor ?? (Get.isDarkMode ? Colors.white : Colors.black),
      unselectedLabelColor:
          unselectedLabelColor ??
          (Get.isDarkMode ? Colors.white60 : Colors.grey),
      dividerColor: dividerColor,
      labelStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      unselectedLabelStyle: TextStyle(
        fontSize: unselectedFontSize,
        fontWeight: unselectdFontWeight,
      ),
      indicator:
          indicator ??
          UnderlineIndicator(
            strokeCap: StrokeCap.round,
            borderSide: BorderSide(color: borderSideColor, width: boderWidth),
            insets: EdgeInsets.only(left: insets, right: insets),
          ),
      // dividerHeight: 0,
      tabs: tabs,
    );
  }
}
