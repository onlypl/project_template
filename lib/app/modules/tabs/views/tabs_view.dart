import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_colors.dart';
import '../controllers/tabs_controller.dart';

class TabsView extends GetView<TabsController> {
  const TabsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        bottomNavigationBar: _buildConvexAppBar(),
        body: PageView.builder(
          //tab页面
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          itemCount: controller.pages.length,
          onPageChanged: (int index) {
            controller.updateCurrentIndex(index);
          },

          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> map = controller.pages[index];
            return map['page'];
          },
        ),
      ),
    );
  }

  ///底部导航栏
  _buildConvexAppBar() {
    ConvexAppBar appBar = ConvexAppBar(
      //底部tabbar
      key: controller.appBarKey,
      initialActiveIndex: controller.currentIndex.value,
      backgroundColor:
          Get.isDarkMode ? AppColor.darkTabBarBgColor : AppColor.tabBarBgColor,
      color:
          Get.isDarkMode
              ? AppColor.darkTabBarUnItemColor
              : AppColor.tabBarUnItemColor,
      activeColor:
          Get.isDarkMode
              ? AppColor.darkTabBarItemColor
              : AppColor.tabBarItemColor,
      elevation: 0.9,
      style: TabStyle.flip,
      items: _buildBottomBarItem(),
      onTap: (index) {
        controller.pageController.jumpToPage(index);
      },
      // onTabNotify: (index) {
      //   if (index == 4) {
      //     return false;
      //   }
      //   return true;
      // },
    );
    return appBar;
  }

  ///底部tabbarItem
  _buildBottomBarItem() {
    List<TabItem> list = [];
    for (int i = 0; i < controller.pages.length; i++) {
      Map<String, dynamic> map = controller.pages[i];
      TabItem item = TabItem(
        title: map['title'],
        icon: ImageIcon(
          AssetImage(map['iconName']),
          size: 24.0,
          color:
              Get.isDarkMode
                  ? AppColor.darkTabBarUnItemColor
                  : AppColor.tabBarUnItemColor,
        ),
        activeIcon: ImageIcon(
          AssetImage(map['iconName']),
          size: 24.0,
          color:
              Get.isDarkMode
                  ? AppColor.darkTabBarItemColor
                  : AppColor.tabBarItemColor,
        ),
      );
      list.add(item);
    }
    return list;
  }
}
