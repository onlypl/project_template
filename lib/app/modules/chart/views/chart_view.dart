import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/app_colors.dart';
import 'package:project_template/app/modules/chart/renderer/main_renderer.dart';
import 'package:project_template/app/widgets/base_appbar.dart';

import '../controllers/chart_controller.dart';
import 'k_chart_widget.dart';

class ChartView extends GetView<ChartController> {
  const ChartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: '走势图', leftWidget: Container()),
      body: ListView(
        children: [
          Wrap(
            children: [
              buildButton(
                '时间模式',
                onPressed: () => controller.isLine.value = true,
              ),
              buildButton(
                'K线模式',
                onPressed: () => controller.isLine.value = false,
              ),
              buildButton(
                '趋势线',
                onPressed:
                    () =>
                        controller.isTrendLine.value =
                            !controller.isTrendLine.value,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            children: [
              buildButton(
                '平均线(MA)',
                onPressed: () => controller.mainState.value = MainState.MA,
              ),
              buildButton(
                '布林线(BOLL)',
                onPressed: () => controller.mainState.value = MainState.BOLL,
              ),
              buildButton(
                '隐藏(NONE)',
                onPressed: () => controller.mainState.value = MainState.NONE,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            children: [
              buildButton(
                '指数平滑异同移动平均线(MACD)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.MACD,
              ),
              buildButton(
                '随机指标(KDJ)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.KDJ,
              ),
              buildButton(
                '相对强弱指标(RSI)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.RSI,
              ),
              buildButton(
                '威廉指标(WR)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.WR,
              ),
              buildButton(
                '商品通道指数(CCI)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.CCI,
              ),
              buildButton(
                '隐藏(NONE)',
                onPressed:
                    () => controller.secondaryState.value = SecondaryState.NONE,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            children: [
              buildButton(
                controller.volHidden.value ? '显示成交量图' : '隐藏成交量图',
                onPressed:
                    () =>
                        controller.volHidden.value =
                            !controller.volHidden.value,
              ),
              buildButton(
                controller.hideGrid.value ? '显示网格线' : '隐藏网格线',
                onPressed:
                    () =>
                        controller.hideGrid.value = !controller.hideGrid.value,
              ),
              buildButton(
                controller.showNowPrice.value ? '隐藏当前价' : '显示当前价',
                onPressed:
                    () =>
                        controller.showNowPrice.value =
                            !controller.showNowPrice.value,
              ),
              buildButton(
                controller.isChinese.value ? '英文' : '中文',
                onPressed:
                    () =>
                        controller.isChinese.value =
                            !controller.isChinese.value,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            children: [
              buildButton(
                '价格文本方向',
                onPressed: () {
                  controller.priceLeft.value = !controller.priceLeft.value;
                  if (controller.priceLeft.value) {
                    controller.verticalTextAlignment.value =
                        VerticalTextAlignment.left;
                  } else {
                    controller.verticalTextAlignment.value =
                        VerticalTextAlignment.right;
                  }
                },
              ),
              buildButton(
                '自定义UI',
                onPressed: () {
                  controller.isChangeUI.value = !controller.isChangeUI.value;
                  if (controller.isChangeUI.value) {
                    controller.chartColors.value.selectBorderColor = Colors.red;
                    controller.chartColors.value.selectFillColor = Colors.red;
                    controller.chartColors.value.lineFillColor = Colors.red;
                    controller.chartColors.value.kLineColor = Colors.yellow;
                  } else {
                    controller.chartColors.value.selectBorderColor = Color(
                      0xff6C7A86,
                    );
                    controller.chartColors.value.selectFillColor = Color(
                      0xff0D1722,
                    );
                    controller.chartColors.value.lineFillColor = Color(
                      0x554C86CD,
                    );
                    controller.chartColors.value.kLineColor = Color(0xff4C86CD);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, {VoidCallback? onPressed}) {
    return Container(
      margin: EdgeInsets.only(left: 12.w, top: 8.h),
      child: TextButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            controller.update();
          }
        },
        style: TextButton.styleFrom(
          //minimumSize: const Size(88, 44),
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          backgroundColor: AppColor.themeColor.withValues(alpha: 0.2),
        ),
        child: Text(
          text,
          style: TextStyle(color: AppColor.themeColor, fontSize: 12.sp),
        ),
      ),
    );
  }
}
