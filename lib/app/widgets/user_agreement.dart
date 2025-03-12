import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../utils/log.dart';

class UserAgreement extends StatefulWidget {
  final bool isAgree; //默认不同意
  final ValueChanged<bool>? onChangedAgree; //修改是否同意
  final ValueChanged<int>? onClickAgreement;

  ///点击协议
  final String endText; //结束文本
  UserAgreement({
    super.key,
    this.isAgree = false,
    this.onChangedAgree,
    this.onClickAgreement,
    this.endText = '未注册的用户将自动注册平台账号',
  });

  @override
  State<UserAgreement> createState() => _UserAgreementState();
}

class _UserAgreementState extends State<UserAgreement> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //    widget.isAgree = !widget.isAgree;
        if (widget.onChangedAgree != null) {
          widget.onChangedAgree!(!widget.isAgree);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            child: Stack(
              children: [
                // Assets.images.common.notAgree.image(width: 14.w, height: 14.w),
                // widget.isAgree
                //     ? Assets.images.common.agree
                //         .image(width: 14.w, height: 14.w)
                //     : SizedBox(
                //         width: 14.w,
                //         height: 14.w,
                //       ),
              ],
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '  我已阅读并同意',
                style: Get.theme.textTheme.bodyMedium,
                children: <InlineSpan>[
                  TextSpan(
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Log().info('点击《服务条款》');
                            if (widget.onClickAgreement != null) {
                              widget.onClickAgreement!(1);
                            }
                          },
                    text: '《服务条款》',
                    style: TextStyle(
                      color: AppColor.themeColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Log().info('点击《隐私权政策》');
                            if (widget.onClickAgreement != null) {
                              widget.onClickAgreement!(2);
                            }
                          },
                    text: '《隐私权政策》',
                    style: TextStyle(
                      color: AppColor.themeColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Log().info('点击《平台声明》');
                            if (widget.onClickAgreement != null) {
                              widget.onClickAgreement!(3);
                            }
                          },
                    text: '《平台声明》',
                    style: TextStyle(
                      color: AppColor.themeColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.endText,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
