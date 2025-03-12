import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../utils/log.dart';

///输入控件
class InputTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText; //提示
  final bool? isObscureText; //是否是密文
  final TextInputType? keyboardType; //键盘类型
  final ValueChanged<String>? onChanged; //文本发生改变监听
  final ValueChanged<bool>? focusChanged; //是否获取到焦点监听
  InputTextField({
    super.key,
    this.controller,
    this.hintText,
    this.isObscureText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.focusChanged,
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  final _foucusNode = FocusNode(); //是否获取到光标
  late bool _isShow; //是否显示显示密码/不显示密码
  @override
  void initState() {
    super.initState();
    _isShow = false;
    //是否获取到焦点监听
    _foucusNode.addListener(() {
      Log().info("是否有焦点:${_foucusNode.hasFocus}");
      if (widget.focusChanged != null) {
        widget.focusChanged!(_foucusNode.hasFocus);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _foucusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyboardType, //软键盘类型
      controller: widget.controller,
      maxLines: 1,
      cursorColor: AppColor.themeColor, //光标颜色
      focusNode: _foucusNode, //焦点控制
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        //刷新是否显示清除按钮 刷新条件 有1个文字/无文字 多余1个则无需重复更新页面
        if ((value.length <= 1)) {
          setState(() {});
        }
      }, //文本发生改变
      autofocus: widget.isObscureText ?? true, //是否自动聚焦 明文为true
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontSize: 14.sp,
        color: Get.isDarkMode ? AppColor.white : AppColor.textColor333,
      ),
      onEditingComplete: () {},
      obscureText:
          widget.isObscureText != null
              ? !(_isShow ?? false)
              : widget.isObscureText ?? false, //是否是密文
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        suffix:
            ///有文字并且有焦点则显示清除按钮
            (widget.controller?.text.length ?? 0) > 0 && _foucusNode.hasFocus
                ? InkWell(
                  onTap: () {
                    //清除文字并刷新
                    widget.controller?.clear();
                    setState(() {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(' '),
                      Icon(
                        Icons.cancel,
                        color: const Color(0xFF969696),
                        size: 15.h,
                      ),
                    ],
                  ),
                )
                : null,

        suffixIcon: _buildShowOrHidePassword(),
        contentPadding: EdgeInsets.only(left: 12.w, right: 12.w), //内间距
        focusColor: Colors.transparent,
        filled: true, //填充背景
        fillColor:
            Get.isDarkMode ? AppColor.textColor444 : AppColor.colorF3, //背景色
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: AppColor.textColor999,
        ), //提示文字样式
        border: OutlineInputBorder(
          //圆角无边框
          borderRadius: BorderRadius.circular(10.h),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  _buildShowOrHidePassword() {
    return widget.isObscureText != null
        ? InkWell(
          onTap: () {
            _isShow = !_isShow;
            setState(() {});
            Log().info('点击右边按钮');
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            child: Center(
              child:
                  _isShow
                      ? Icon(Icons.egg_outlined, size: 20)
                      : Icon(Icons.egg, size: 20),
            ),
            // child: _isShow
            //     ? Assets.images.common.showPassword
            //         .image(width: 20.w, height: 20.h)
            //     : Assets.images.common.hidePassword
            //         .image(width: 20.w, height: 20.h)),
          ),
        )
        : null;
  }
}
