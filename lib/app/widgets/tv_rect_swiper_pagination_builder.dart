import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

//轮播图指示器
class TvRectSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the rect when activate
  final Size activeSize;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;
  final double circular;
  final Key? key;

  const TvRectSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = const Size(10.0, 3.0),
    this.activeSize = const Size(10.0, 3.0),
    this.space = 2.0,
    this.circular = 1.5,
  });
  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    int itemCount = config.itemCount;
    if (itemCount <= 1) {
      return Container();
    }

    ThemeData themeData = Theme.of(context);
    Color activeColor = this.activeColor ?? themeData.primaryColor;
    Color color = this.color ?? themeData.scaffoldBackgroundColor;

    List<Widget> list = [];

    int activeIndex = config.activeIndex;
    if (itemCount > 20) {
      debugPrint(
        "The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this situation",
      );
    }

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      Size size = active ? activeSize : this.size;
      list.add(
        Container(
          width: size.width,
          height: size.height,
          key: Key("pagination_$i"),
          margin: EdgeInsets.all(space),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circular),
            color: active ? activeColor : color,
          ),
        ),
      );
    }

    if (config.scrollDirection == Axis.vertical) {
      return Column(key: key, mainAxisSize: MainAxisSize.min, children: list);
    } else {
      return Row(key: key, mainAxisSize: MainAxisSize.min, children: list);
    }
  }
}
