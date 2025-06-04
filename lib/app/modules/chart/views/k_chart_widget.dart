import 'package:flutter/material.dart';
import 'package:project_template/app/modules/chart/model/k_line_model.dart';

import '../renderer/chart_painter.dart';
import '../utils/date_format_util.dart';
import 'chart_style.dart';

enum MainState {
  ///平均线
  MA,
  ///布林线
  BOLL,
  ///无
  NONE,
}

enum SecondaryState {
  /// 指数平滑异同移动平均线
  MACD,
  ///随机指标
  KDJ,
  ///相对强弱指标
  RSI,
  /// 威廉指标
  WR,
  ///商品通道指数
  CCI,
  ///无
  NONE,
}

///日期格式化
class TimeFormat {
  ///年-月-日
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn,
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineModel>? datas;
  final ChartColors chartColors; //颜色配置
  final ChartStyle chartStyle; //间距宽高等样式配置
  const KChartWidget({
    super.key,
    required this.datas,
    required this.chartColors,
    required this.chartStyle,
  });

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  ///mScaleX 缩放比例 控制图表缩放级别（如手势放大/缩小）
  ///mScrollX 滑动偏移量 控制图表滑动（如手势滑动）
  ///mSelectX 选中的点的位置 控制选中的点的位置
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;

  ///图表总宽和总高
  double mHeight = 0, mWidth = 0;
  @override
  Widget build(BuildContext context) {
    //数组没有数据 初始化参数：选中位置 滑动偏移 缩放比例
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }

    ///图表画
    // final _painter = ChartPainter(scaleX: null);
    return LayoutBuilder(
      builder: (context, constraints) {
        //获取父容器的最大宽高
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;
        return GestureDetector(
          ///手指抬起
          onTapUp: (details) {},

          ///水平拖动-开始
          onHorizontalDragDown: (details) {},

          ///水平拖动-结束
          onHorizontalDragEnd: (details) {},

          ///水平拖动-取消
          onHorizontalDragCancel: () {},

          ///缩放-开始
          onScaleStart: (details) {},

          ///缩放-进行中
          onScaleUpdate: (details) {},

          ///缩放-结束
          onScaleEnd: (details) {},

          ///长按-开始
          onLongPressStart: (details) {},

          ///长按-移动中
          onLongPressMoveUpdate: (details) {},

          ///长按-结束
          onLongPressEnd: (details) {},

          ///
          child: Stack(
            children: [
              //自定义绘图
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: _painter,
              ),
              // if (widget.showInfoDialog) _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
