import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';
import 'package:project_template/app/models/message_model.dart';
import 'package:project_template/app/utils/format_util.dart';
import 'package:project_template/app/utils/view_utils.dart';

import '../../../utils/log.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('聊天室'), centerTitle: true),

      body: _buildChatPage(context),
    );
  }

  _buildChatPage(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Obx(() {
              return ListView.builder(
                controller: controller.listViewScrollController,
                itemCount: controller.messageList.length,
                padding: EdgeInsets.only(bottom: 10.h),
                itemBuilder: (BuildContext context, int index) {
                  MessageModel model = controller.messageList[index];
                  if (model.type == 'join') {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        model.data ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.textColor666,
                          fontSize: 13.sp,
                        ),
                      ),
                    );
                  }
                  return _buildtChatItem(
                    model,
                    index,
                    isRight: model.isMe ?? false,
                  );
                },
              );
            }),
          ),
          _buildBottomSendMsg(context),
        ],
      ),
    );
  }

  ///聊天内容item
  _buildtChatItem(MessageModel model, int index, {bool isRight = false}) {
    DateTime nowDateTime = DateTime.parse(model.time ?? '');
    String showTime = model.time ?? '';
    if (index - 1 > 1) {
      //包含系统加入聊天室的第3条数据
      MessageModel previousModel = controller.messageList[index - 1];
      showTime = formatRelativeTime(
        DateTime.parse(previousModel.time ?? ''),
        nowDateTime,
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Text(
              showTime,
              style: TextStyle(color: AppColor.textColor666, fontSize: 10.sp),
            ),
          ),

          isRight
              ?
              //我的
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    model.nickName ?? '',
                    style: Get.theme.textTheme.titleLarge,
                  ),
                  lineSpace(width: 12.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18.w),
                    child: cachedImage(
                      model.avatarUrl ?? '',
                      width: 36.w,
                      height: 36.w,
                    ),
                  ),
                ],
              )
              :
              //其他人的
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18.w),
                    child: cachedImage(
                      model.avatarUrl ?? '',
                      width: 36.w,
                      height: 36.w,
                    ),
                  ),
                  lineSpace(width: 12.w),
                  Text(
                    model.nickName ?? '',
                    style: Get.theme.textTheme.titleLarge,
                  ),
                ],
              ),
          Container(
            margin: EdgeInsets.only(top: 10.h),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 15.h,
              bottom: 15.h,
            ),
            decoration: BoxDecoration(
              color: isRight ? hexColor('#9971EE') : hexColor('#FA6CB4'),
              borderRadius: BorderRadius.only(
                topLeft: isRight ? Radius.circular(30) : Radius.zero,
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: isRight ? Radius.zero : Radius.circular(30),
              ),
            ),
            child: Text(
              model.data ?? '',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  ///底部发送消息面板
  _buildBottomSendMsg(BuildContext context) {
    return Obx(
      () => Container(
        key: controller.bottomKey,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.black : AppColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 5), // 阴影的垂直偏移量
              blurRadius: 5, // 模糊半径
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom:
              controller.keyboardVisible.value
                  ? 10.h
                  : controller.bottomPading + 10.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _buildInput(context)),
            Container(
              margin: EdgeInsets.only(top: 10.h, right: 12.w),
              child: TextButton(
                onPressed: () {
                  Log().info('点击发送');
                  controller.sendChatMessage();
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      controller.sendText.value.isEmpty
                          ? Colors.grey
                          : AppColor.themeColor,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size(35.w, 30.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.h), // 设置圆角半径
                  ),
                ),
                child: Text(
                  '发送',
                  style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///输入框
  _buildInput(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w, top: 10.h),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(15.h),
      ),
      child: TextField(
        // maxLines: 3,
        minLines: 1,
        maxLines: 3,
        focusNode: controller.focusNode,
        keyboardType: TextInputType.multiline,
        //这两句设置文本框高度自适应
        //  autofocus: true,
        //获取焦点
        controller: controller.textEditingController,
        onSubmitted: (value) {
          var text = value.trim();

          //  _send(text, context);
        },
        onChanged: (value) {
          controller.changeSendText(value);
        },
        cursorColor: AppColor.themeColor,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 13.w, color: Colors.grey),
          hintText: '说点什么吧~',
        ),
        style: TextStyle(
          fontSize: 13.sp,
          color: Get.isDarkMode ? AppColor.white : AppColor.textColor333,
        ),
      ),
    );
  }
}
