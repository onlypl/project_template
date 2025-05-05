import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/gen/assets.gen.dart';

import '../../../utils/log.dart';
import '../../bloc/views/bloc_view.dart';
import '../../chart/views/chart_view.dart';
import '../../home/views/home_view.dart';
import '../../mine/views/mine_view.dart';
import '../../other/views/other_view.dart';

class TabsController extends GetxController {
  RxInt currentIndex = 0.obs;
  PageController pageController = PageController(initialPage: 0);
  GlobalKey<ConvexAppBarState> appBarKey = GlobalKey<ConvexAppBarState>();
  final List<Map<String, dynamic>> pages = [
    {
      'title': '首页',
      'iconName': Assets.images.tabs.homeSelected.path,
      'page': HomeView(),
    },
    {
      'title': 'Bloc',
      'iconName': Assets.images.tabs.topicsSelected.path,
      'page': const BlocView(),
    },
    {
      'title': '交易所',
      'iconName': Assets.images.tabs.rangkingSelected.path,
      'page': const ChartView(),
    },
    {
      'title': '其它',
      'iconName': Assets.images.tabs.discoverSelected.path,
      'page': const OtherView(),
    },
    {
      'title': '我的',
      'iconName': Assets.images.tabs.mineSelected.path,
      'page': const MineView(),
    },
  ];
  @override
  void onInit() {
    super.onInit();
  }

  void updateCurrentIndex(index) {
    Log().info('${index}');
    // bool isLogin = false;
    // if (index == 4 && !isLogin) {
    //   Log().info('未登录');
    //   pageController.previousPage(
    //     duration: Duration(milliseconds: 10),
    //     curve: Curves.easeInOut,
    //   );
    //   Get.toNamed(Routes.LOGIN);
    // } else {
    currentIndex.value = index;
    appBarKey.currentState?.animateTo(index);
    update();
    //   }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
  }
}
