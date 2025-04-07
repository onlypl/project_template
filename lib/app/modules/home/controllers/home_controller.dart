import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_template/app/utils/log.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  void onInit() {
    super.onInit();
    // 设置焦点到 TextField 上，以便键盘自动弹出
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  submitData() {
    if (textEditingController.text.trim().isEmpty) {
      BotToast.showText(text: '请输入昵称');
      return;
    }
    Get.back();
    Get.focusScope?.unfocus();
    Log().info(textEditingController.text.trim());

    Future.delayed(Duration(milliseconds: 600), () {
      Get.toNamed(
        Routes.CHAT,
        arguments: {'nickName': textEditingController.text.trim()},
      );
      textEditingController.text = '';
    });
  }
}
