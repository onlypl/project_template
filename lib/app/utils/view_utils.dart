import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'format_util.dart';

final Size hotVideoSize = Size(
  videoWidth(1.sw, space: 30.w, scale: 0.4),
  videoHeight(videoWidth(1.sw, space: 30.w, scale: 0.4)),
);

final Size videoSize = Size(
  videoWidth(1.sw, space: 44.w, itemCount: 3),
  videoHeight(videoWidth(1.sw, space: 44.w, itemCount: 3)),
);

///带缓存的image
Widget cachedImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget? placeholderImg,
  bool isShowPlaceholderImg = true,
}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    //  cacheManager: EsoImageCacheManager(),
    width: width,
    height: height,
    fit: BoxFit.cover,
    placeholder:
        isShowPlaceholderImg == false
            ? null
            : (BuildContext context, String url) {
              return placeholderImg ??
                  // Assets.images.common.imgDefault.image(
                  //   width: width,
                  //   height: height,
                  //   fit: BoxFit.cover,
                  // );
                  Container(color: Colors.grey[200]);
              // return Container(color: Colors.grey[200]);
            },
    // errorWidget: (
    //   BuildContext context,
    //   String url,
    //   Object error,
    // ) =>
    //     const Icon(
    //   Icons.error,
    //   color: Colors.red,
    // ),
  );
}

///黑色线性渐变
blackLinearGradient({bool fromTop = false}) {
  return LinearGradient(
    begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
    end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
    colors: const [
      Colors.black54,
      Colors.black45,
      Colors.black26,
      Colors.black12,
      Colors.transparent,
    ],
  );
}

///带文字的小图标
smallIconText(
  IconData? iconData,
  var text, {
  double textLeft = 5,
  Color iconColor = Colors.grey,
  double iconSize = 12,
  TextStyle style = const TextStyle(fontSize: 12, color: Colors.grey),
}) {
  if (text is int) {
    text = countFormat(text);
  }

  return [
    if (iconData != null) Icon(iconData, color: iconColor, size: iconSize),
    Padding(
      padding: EdgeInsets.only(left: iconData != null ? textLeft : 0),
      child: Text(text, style: style),
    ),
  ];
}

///组件间隙
Container lineSpace({double height = 1, double width = 1, Color? color}) {
  return Container(width: width, height: height, color: color);
}

///底部阴影
BoxDecoration? bottomBoxShadow() {
  return BoxDecoration(
    color: Colors.transparent,
    boxShadow: [
      BoxShadow(
        offset: const Offset(0, 5), //xy轴偏移量
        color: (Colors.grey[100])!,
        blurRadius: 5, //阴影 模糊程度
        spreadRadius: 1, //阴影扩散程度
      ),
    ],
  );
}

///Border线条
borderLine(
  BuildContext context, {
  bottom = true,
  top = false,
  width = 0.5,
  color = Colors.grey,
}) {
  BorderSide borderSide = BorderSide(width: width, color: color);
  return Border(
    bottom: bottom ? borderSide : BorderSide.none,
    top: top ? borderSide : BorderSide.none,
  );
}

///状态栏颜色设置，此方法抽出来了，全项目可以直接调用
getSystemUiOverlayStyle({bool isDark = true}) {
  SystemUiOverlayStyle value;
  if (Platform.isAndroid) {
    value = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,

      /// 安卓系统状态栏存在底色，所以需要加这个
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,

      /// 状态栏字体颜色
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  } else {
    value = isDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;
  }
  return value;
}

///视频封面宽高比例 2:3
double videoWidth(
  double width, {
  double space = 0,
  int itemCount = 1,
  double scale = 1.0,
}) {
  return (width - space) / itemCount * scale;
}

double videoHeight(double width) {
  return width / 2 * 3;
}

///去掉html标签
String removeHtmlTags(String htmlString) {
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlString.replaceAll(exp, '');
}

///跳转登录页面
// Future? toLoginPage() async {
//   return await Get.to(
//     const LoginView(),
//     binding: LoginBinding(),
//     transition: Transition.downToUp,
//     duration: const Duration(milliseconds: 300),
//   );
// }
