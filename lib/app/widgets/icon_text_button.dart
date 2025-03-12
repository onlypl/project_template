import 'package:flutter/material.dart';

///图文按钮
enum IconTextAlignment {
  iconTopTextBottom, //图在上文字在下
  iconBottomTextTop, //图在下文字在上
  iconLeftTextRight, //图在左文字在右
  iconRightTextLeft, //图在右文字在左
}

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.alignment,
    this.borderRadius,
    this.interval = 4.0,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.elevation,
    this.disabledElevation,
    this.padding,
    this.shape,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.colorBrightness,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.enableFeedback = true,
    this.minWidth,
    this.height,
    this.iconSize,
  });

  ///图文按钮-图片/图标
  /// 注意：如果要设置按钮禁用状态的图标颜色，不要设置 Icon 颜色
  ///  - 可以直接设置 ImageButton的 textColor 和 disabledTextColor
  final Widget icon;

  ///图文按钮-文字
  /// 注意：如果要设置按钮禁用状态的文字颜色，不要设置 label 文字颜色
  ///     - 可以直接设置 ImageButton的 textColor 和 disabledTextColor
  final String text;

  ///图文按钮-点击事件
  final void Function() onPressed;

  ///图文按钮-长按事件
  final void Function()? onLongPress;

  ///图文按钮-对齐方式
  ///
  /// - iconTopTextBottom,//图在上文字在下
  ///
  /// - iconBottomTextTop,//图在下文字在上
  ///
  /// - iconLeftTextRight,//图在左文字在右
  ///
  /// - iconRightTextLeft,//图在右文字在左
  ///
  /// 默认 iconLeftTextRight 图在左文字在右
  final IconTextAlignment? alignment;

  ///图文按钮-圆角设置
  final BorderRadius? borderRadius;

  ///图文按钮-图片和文字之间的间隔
  /// - 默认间隔 4.0
  final double interval;

  ///图文按钮- 文字的颜色
  final Color? textColor;

  ///图文按钮- 禁用状态文字的颜色
  final Color? disabledTextColor;

  final double? fontSize;
  final double? iconSize;
  final FontWeight? fontWeight;

  ///图文按钮-下方阴影的大小
  final Color? backgroundColor;

  ///图文按钮-禁用状态背景色
  final Color? disabledBackgroundColor;

  ///图文按钮-下方阴影的大小(注意-如果无效，请检查是否设置了背景色)
  /// 如果想把背景色设置为透明色，但是有灰色背景，请将 elevation 设置为 0
  final double? elevation;

  ///图文按钮-禁用状态阴影
  final double? disabledElevation;

  ///图文按钮-内边距
  final EdgeInsetsGeometry? padding;

  ///图文按钮-其他一些设置
  final ShapeBorder? shape;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Brightness? colorBrightness;

  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final bool enableFeedback;

  final double? minWidth;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      elevation: elevation,
      color: backgroundColor,
      textColor: Colors.green,
      disabledColor: disabledBackgroundColor,
      disabledTextColor: disabledTextColor,
      disabledElevation: disabledElevation,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // 圆角的半径
          ),
      padding: padding,
      focusColor: focusColor,
      focusElevation: focusElevation,
      hoverColor: hoverColor,
      hoverElevation: hoverElevation,
      highlightColor: highlightColor,
      highlightElevation: highlightElevation,
      splashColor: splashColor,
      enableFeedback: enableFeedback,
      minWidth: minWidth,
      height: height,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: _buildChildWidget(),
    );
  }

  /// 获取对齐方式
  IconTextAlignment getIconTextAlignment() {
    if (alignment == null) {
      return IconTextAlignment.iconLeftTextRight;
    }
    return alignment!;
  }

  _buildChildWidget() {
    Text label = Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    switch (getIconTextAlignment()) {
      // 图在左文字在右
      case IconTextAlignment.iconLeftTextRight:
        {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon, SizedBox(width: interval), label],
          );
        }

      //图在右文字在左
      case IconTextAlignment.iconRightTextLeft:
        {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [label, SizedBox(width: interval), icon],
          );
        }

      //图在上文字在下
      case IconTextAlignment.iconTopTextBottom:
        {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon, SizedBox(height: interval), label],
          );
        }

      // 图在下文字在上
      case IconTextAlignment.iconBottomTextTop:
        {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [label, SizedBox(height: interval), icon],
          );
        }
    }
  }
}
