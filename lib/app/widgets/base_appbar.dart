import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';

import '../../gen/assets.gen.dart';

const double _elevation = 0;
const double _titleFontSize = 18.0;
const double _textFontSize = 16.0;
const double _itemSpace = 15.0; // 右侧item内间距
const double _imgWH = 22.0; // 右侧图片宽高
const double _rightSpace = 5.0; // 右侧item右间距
// 状态栏字体颜色，当backgroundColor透明或者是白色，状态栏字体为黑色，暗黑模式为白色
const Brightness _brightness = Brightness.light;
const Color appbarStartColor = AppColor.gradientStartColor; // 默认appBar 渐变开始色
const Color appbarEndColor = AppColor.gradientEndColor; // 默认appBar 渐变结束色

/// 渐变导航条
class GradientAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GradientAppBar(
    this.title, {
    Key? key,
    this.rightText,
    this.rightImgPath,
    this.leftWidget,
    this.titleWidget,
    this.rightWidgets,
    this.brightness = _brightness,
    this.elevation = _elevation,
    this.bottomWidget,
    this.leftItemCallBack,
    this.rightItemCallBack,
  }) : super(key: key);

  final String title;
  final String? rightText;
  final String? rightImgPath;
  final Widget? leftWidget;
  final Widget? titleWidget;
  final List<Widget>? rightWidgets;
  final Brightness brightness;
  final double elevation;
  final PreferredSizeWidget? bottomWidget;
  final Function? leftItemCallBack;
  final Function? rightItemCallBack;

  @override
  State<GradientAppBar> createState() => _GradientAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottomWidget?.preferredSize.height ?? 0.0),
  );
}

class _GradientAppBarState extends State<GradientAppBar> {
  @override
  Widget build(BuildContext context) {
    var flexibleSpace = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [appbarStartColor, appbarEndColor],
        ),
      ),
    );
    return BaseAppBar(
      title: widget.title,
      rightText: widget.rightText,
      rightImgPath: widget.rightImgPath,
      leftWidget: widget.leftWidget,
      titleWidget: widget.titleWidget,
      rightWidgets: widget.rightWidgets,
      bgColor: Colors.white.withOpacity(0),
      elevation: widget.elevation,
      bottomWidget: widget.bottomWidget,
      rightItemCallBack: widget.rightItemCallBack,
      leftItemCallBack: widget.leftItemCallBack,
      flexibleSpace: flexibleSpace,
    );
  }
}

class BaseAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget; // 标题Widget，优先级高于title
  final double? leadingWidth;
  final PreferredSizeWidget? bottomWidget;
  final Function? leftItemCallBack;
  final Function? rightItemCallBack;
  final String? rightText; // 右侧按钮文字
  final String? rightImgPath; // 右侧按钮图片路径，优先级高于rightText
  final Widget? leftWidget; // 左侧Widget，为空显示返回按钮
  final List<Widget>? rightWidgets; // 优先级高于rightText和rightImgPath
  final Brightness brightness;
  final double elevation;
  final Widget? flexibleSpace;
  final Color? bgColor; // 背景颜色，默认主题色，设置的颜色优先级高于暗黑模式
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final double? titleSpacing;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Color? titleColor;
  const BaseAppBar({
    super.key,
    required this.title,
    this.leadingWidth,
    this.bottomWidget,
    this.leftItemCallBack,
    this.rightItemCallBack,
    this.rightText,
    this.rightImgPath,
    this.leftWidget,
    this.rightWidgets,
    this.brightness = _brightness,
    this.elevation = _elevation,
    this.flexibleSpace,
    this.titleWidget,
    this.bgColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.titleSpacing,
    this.systemOverlayStyle,
    this.titleColor,
  });

  @override
  State<BaseAppBar> createState() => _BaseAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(56 + (bottomWidget?.preferredSize.height ?? 0.0));
}

class _BaseAppBarState extends State<BaseAppBar> {
  @override
  Widget build(BuildContext context) {
    return _appBar(context);
  }

  Widget _appBar(BuildContext context) {
    // ThemeData themeData = Theme.of(context);
    Color? bgColor = widget.bgColor ?? Get.theme.appBarTheme.backgroundColor;
    // 标题
    var titleWidget =
        widget.titleWidget ??
        Text(
          widget.title,
          style: TextStyle(
            fontSize: _titleFontSize,
            color:
                widget.titleColor ??
                Get.theme.appBarTheme.titleTextStyle?.color,
          ),
          maxLines: 2,
        );
    // 左侧
    var backWidget = IconButton(
      //      icon: Icon(Icons.arrow_back_ios,color: _color),
      icon: Assets.images.common.back.image(
        color: Get.isDarkMode ? AppColor.white : AppColor.textColor666,
        width: 24,
        height: 24,
      ),
      iconSize: 24,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      onPressed: () {
        if (widget.leftItemCallBack == null) {
          Get.back();
        } else {
          widget.leftItemCallBack!();
        }
      },
    );
    var leftWidget = widget.leftWidget ?? backWidget;

    // 右侧
    Widget rightWidget = const Text('');
    if (widget.rightText != null) {
      rightWidget = InkWell(
        child: Container(
          margin: const EdgeInsets.all(_itemSpace),
          color: Colors.transparent,
          child: Center(
            child: Text(
              widget.rightText!,
              style: TextStyle(
                fontSize: _textFontSize,
                color: Get.theme.appBarTheme.titleTextStyle?.color,
              ),
            ),
          ),
        ),
        onTap: () => widget.rightItemCallBack?.call(),
      );
    }

    if (widget.rightImgPath != null) {
      rightWidget = IconButton(
        icon: Image.asset(
          widget.rightImgPath!,
          width: _imgWH,
          height: _imgWH,
          color: Get.theme.appBarTheme.titleTextStyle?.color,
        ),
        onPressed: () => widget.rightItemCallBack?.call(),
      );
    }
    var actions = [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[rightWidget, const SizedBox(width: _rightSpace)],
      ),
    ];
    var rightWidgets = widget.rightWidgets ?? actions;
    return AppBar(
      title: titleWidget,
      backgroundColor: bgColor,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Get.theme.appBarTheme.titleTextStyle?.color,
      ),
      bottom: widget.bottomWidget,
      elevation: widget.elevation,
      leading: leftWidget,
      actions: rightWidgets,
      flexibleSpace: widget.flexibleSpace,
      titleSpacing: widget.titleSpacing,
      shadowColor: widget.shadowColor,
      surfaceTintColor: widget.surfaceTintColor ?? bgColor,
      systemOverlayStyle: widget.systemOverlayStyle,
      // leading: IconButton(
      //   onPressed: () {
      //     Get.back();
      //   },
      //   icon: Assets.images.common.back.image(),
      //   style: ButtonStyle(iconSize: MaterialStateProperty.all(14)),
      // ),
      leadingWidth: widget.leadingWidth,
      // actions: widget.actions,
    );
  }
}

// 多行标题
class TwoLinesTitle extends StatelessWidget {
  const TwoLinesTitle({
    Key? key,
    this.title = '',
    this.subtitle = '',
    this.color,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    Color? textColor = color ?? Get.theme.appBarTheme.titleTextStyle?.color;
    if (subtitle.isEmpty) {
      widget = Text(
        title,
        style: TextStyle(fontSize: _titleFontSize, color: textColor),
      );
    } else {
      widget = RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: title,
          style: TextStyle(fontSize: 20, color: textColor),
          children: <TextSpan>[
            TextSpan(
              text: '\n$subtitle',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return widget;
  }
}
