import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    // Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(title: const Text('Demo首页'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Obx(
            //   () => Text(
            //     (Get.find<ChatController>().messageList.isEmpty
            //         ? '无'
            //         : Get.find<ChatController>().messageList.last.data ?? ''),
            //   ),
            // ),
            TextButton(
              onPressed: () {
                print('进入聊天室');
                _buildDialog(title: '输入昵称');
                // Get.toNamed(Routes.CHAT);
              },
              child: Text('进入聊天室'),
              style: ButtonStyle(
                // 文字颜色（包括禁用状态）
                foregroundColor: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.disabled)) return Colors.grey;
                  return Colors.white;
                }),
                backgroundColor: WidgetStatePropertyAll(AppColor.themeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDialog({
    String? title,
    String cancelTitle = '取消',
    String confirmTitle = '确定',
  }) {
    Get.dialog(
      barrierDismissible: true,
      // useSafeArea: true,
      barrierColor: Colors.black.withOpacity(0.4),

      ///不设置此属性不会有淡入淡出的效果，这里相当于给模糊层设置了一个淡入淡出的效果
      transitionDuration: const Duration(milliseconds: 500),
      AlertDialog(
        title: Container(
          padding: EdgeInsets.only(top: 12.h, right: 5.w, left: 5.w),
          child: Text(
            title ?? '',
            style: const TextStyle(
              color: AppColor.textColor333,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        content: Container(
          width: 200.w,
          //   height: 50.h,
          decoration: BoxDecoration(
            color: hexColor('EDEDED'),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            // maxLength: 15,
            maxLines: 1,

            //这两句设置文本框高度自适应
            autofocus: true,
            //获取焦点
            focusNode: controller.focusNode,
            controller: controller.textEditingController,
            onSubmitted: (value) {
              controller.submitData();
            },
            onChanged: (value) {
              //controller.changeSendText(value);
            },
            cursorColor: AppColor.themeColor,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 13.w, color: Colors.grey),
              hintText: '请输入昵称~',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              color: Get.isDarkMode ? AppColor.white : AppColor.textColor333,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.textEditingController.text = '';
            },
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              minimumSize: Size(108.w, 40.h),
              backgroundColor: hexColor('FA6CB4').withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.h), // 设置圆角半径
              ),
            ),
            child: Text(
              cancelTitle.tr,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.submitData();
            },
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              minimumSize: Size(108.w, 40.h),
              backgroundColor: AppColor.themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.h), // 设置圆角半径
              ),
            ),
            child: Text(
              confirmTitle.tr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
