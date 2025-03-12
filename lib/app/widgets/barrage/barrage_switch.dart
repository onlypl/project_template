import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';

import '../../../gen/assets.gen.dart';

///弹幕显示开关及点击弹出发送
class BarrageSwitch extends StatefulWidget {
  /// 初始时是否展开
  final bool initSwitch;

  /// 是否为输入中
  final bool inoutShowing;

  /// 输入框切换回调
  final VoidCallback onShowInput;

  /// 展开与伸缩状态切换回调
  final ValueChanged<bool> onBarrageSwitch;
  const BarrageSwitch({
    super.key,
    this.initSwitch = true,
    required this.onShowInput,
    required this.onBarrageSwitch,
    this.inoutShowing = false,
  });

  @override
  State<BarrageSwitch> createState() => _BarrageSwitchState();
}

class _BarrageSwitchState extends State<BarrageSwitch> {
  late bool _barrageSwitch;
  @override
  void initState() {
    super.initState();
    _barrageSwitch = widget.initSwitch;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      //padding: EdgeInsets.only(left: 5.w),
      margin: EdgeInsets.only(right: 15.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[100],
        border: Border.all(
          color: Get.isDarkMode ? AppColor.darkTextColor666 : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(15.h),
      ),
      child: Row(children: [_buildText(), _buildIcon()]),
    );
  }

  //文本
  _buildText() {
    var text = widget.inoutShowing ? '弹幕输入中' : '点我发弹幕';
    return InkWell(
      onTap: () {
        widget.onShowInput();
      },
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(15.h),
        topLeft: Radius.circular(15.h),
      ),
      child: AnimatedContainer(
        height: 30.h,
        width: _barrageSwitch ? 85.w : 0,
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 200),
        onEnd: () {},
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ),
    );
  }

  /// 图标
  _buildIcon() {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(15.h)),
      onTap: () {
        setState(() {
          _barrageSwitch = !_barrageSwitch;
        });
        widget.onBarrageSwitch(_barrageSwitch);
      },
      child: Container(
        height: 30.h,
        padding: EdgeInsets.only(left: 8.w, right: 8.w),
        decoration: BoxDecoration(
          color:
              _barrageSwitch == true
                  ? Get.isDarkMode
                      ? AppColor.black
                      : AppColor.white
                  : Get.isDarkMode
                  ? AppColor.black
                  : Colors.grey[100],
          borderRadius:
              _barrageSwitch == true
                  ? BorderRadius.only(
                    bottomRight: Radius.circular(15.h),
                    topRight: Radius.circular(15.h),
                  )
                  : BorderRadius.all(Radius.circular(15.h)),
        ),
        child:
            _barrageSwitch == true
                ? Get.isDarkMode
                    ? Assets.images.barrage.danmuClickCloseWhite.image(
                      width: 24.w,
                      height: 24.w,
                    )
                    : Assets.images.barrage.danmuClickClose666.image(
                      width: 24.w,
                      height: 24.w,
                    )
                : Get.isDarkMode
                ? Assets.images.barrage.danmuClickOpenWhite.image(
                  width: 24.w,
                  height: 24.w,
                )
                : Assets.images.barrage.danmuClickOpen666.image(
                  width: 24.w,
                  height: 24.w,
                ),
      ),
    );
  }
}
