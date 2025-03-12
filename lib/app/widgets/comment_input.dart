import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';

///评论输入控件
class CommentInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? text;
  const CommentInput({super.key, this.onChanged, this.onSubmitted, this.text});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
  }

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
                Navigator.of(context).pop();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          //安全区域控件
          SafeArea(
            child: Container(
              color: Get.isDarkMode ? AppColor.black : AppColor.white,
              child: Row(
                children: [
                  _buildInput(_textEditingController, context),
                  _buildSendBtn(_textEditingController, context),
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
        margin: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 10.h,
          bottom: 10.h,
        ),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15.h),
        ),
        child: TextField(
          // maxLines: 3,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline, //这两句设置文本框高度自适应
          autofocus: true, //获取焦点
          controller: textEditingController,
          onSubmitted: (value) {
            var text = value.trim();
            _send(text, context);
          },
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            if (value.length <= 1) {
              setState(() {});
            }
          },
          cursorColor: AppColor.themeColor,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 5.h),
            border: InputBorder.none,
            hintStyle: TextStyle(fontSize: 12.w, color: Colors.grey),
            hintText: '哎哟, 不错哦, 发条评论吧~',
            // color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[100],
            // borderRadius: BorderRadius.circular(15.h),
          ),
          style: TextStyle(
            fontSize: 12.sp,
            color: Get.isDarkMode ? AppColor.white : AppColor.textColor333,
          ),
        ),
      ),
    );
  }

  ///发送消息
  void _send(String text, BuildContext context) {
    if (text.isNotEmpty) {
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(text);
      }
    }
  }

  //发送按钮
  _buildSendBtn(
    TextEditingController textEditingController,
    BuildContext context,
  ) {
    return Container(
      //padding: const EdgeInsets.only(right: 10, left: 10),
      margin: EdgeInsets.only(right: 12.w),
      child: TextButton(
        onPressed: () {
          var text = textEditingController.text.trim();
          _send(text, context);
        },
        style: TextButton.styleFrom(
          backgroundColor:
              textEditingController.text.isNotEmpty
                  ? AppColor.themeColor
                  : Colors.grey,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //padding: EdgeInsets.zero,asas
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
    );
  }
}
