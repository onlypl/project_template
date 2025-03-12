import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';

//渐变按钮
class SubmitBtn extends StatelessWidget {
  const SubmitBtn({super.key, this.onTapCallBack, this.titile = '提交'});
  final Function? onTapCallBack;
  final String titile;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexColor('FB8864'), AppColor.themeColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(6.h),
        ),
        child: Center(
          child: Text(
            titile.tr,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      onTap: () {
        if (onTapCallBack != null) {
          onTapCallBack!();
        }
      },
    );
    ;
  }
}
