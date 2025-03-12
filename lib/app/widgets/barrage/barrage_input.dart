import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/app_colors.dart';
import '../../utils/view_utils.dart';

///弹幕输入界面
class BarrageInput extends StatefulWidget {
  final VoidCallback? onTabClose;

  ///发送弹幕
  // final ValueChanged<String>? onSendBarrage;
  const BarrageInput({
    super.key,
    this.onTabClose,
    //  this.onSendBarrage,
  });
  @override
  State<BarrageInput> createState() => _BarrageInputState();
}

class _BarrageInputState extends State<BarrageInput> {
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          //空白区域点击关闭弹窗
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.onTabClose != null) {
                  widget.onTabClose!();
                }
                Navigator.of(context).pop();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Container(
              color: Get.isDarkMode ? AppColor.black : AppColor.white,
              child: Row(
                children: [
                  lineSpace(width: 15.w),
                  _buildInput(textEditingController, context),
                  _buildSendBtn(textEditingController, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///输入框
  _buildInput(
    TextEditingController textEditingController,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[200],
          borderRadius: BorderRadius.circular(26),
        ),
        child: TextField(
          autofocus: true, //获取焦点
          controller: textEditingController,
          onSubmitted: (value) {
            _send(value, context);
          },
          onChanged: (value) {
            if (value.trim().length <= 1) {
              setState(() {});
            }
          },
          style: TextStyle(
            color: Get.isDarkMode ? AppColor.white : AppColor.textColor333,
          ),
          cursorColor: AppColor.themeColor,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
            border: InputBorder.none,
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
            hintText: '发送个友善的弹幕见证当下',
          ),
        ),
      ),
    );
  }

  ///发送消息
  void _send(String text, BuildContext context) {
    if (text.isNotEmpty) {
      if (widget.onTabClose != null) {
        widget.onTabClose!();
        Navigator.pop(context, text);
      }
    }
  }

  //发送按钮
  _buildSendBtn(
    TextEditingController textEditingController,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        var text = textEditingController.text.trim();
        _send(text, context);
      },
      child: Container(
        padding: EdgeInsets.only(right: 10.w, left: 10.w),
        child: Icon(
          Icons.send_rounded,
          color:
              textEditingController.text.trim().isEmpty
                  ? Colors.grey
                  : AppColor.themeColor,
        ),
      ),
    );
  }
}
