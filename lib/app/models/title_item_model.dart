import 'dart:ui';

/// title : ""
/// icon : ""

class TitleItemModel {
  TitleItemModel({
    this.icon,
    this.title,
    this.subTitle,
    this.hasArrow,
    this.rightIcon,
    this.routes,
    this.differentTag,
    this.index,
    this.isChecked,
    this.subTitleColor,
    this.params,
  });

  String? title;
  String? subTitle;
  String? icon;
  bool? hasArrow;
  String? rightIcon;
  String? routes;
  String? params;
  int? differentTag;
  int? index;
  bool? isChecked;
  Color? subTitleColor;
}
