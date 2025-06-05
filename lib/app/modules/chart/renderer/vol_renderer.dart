import 'package:flutter/cupertino.dart';
import 'package:project_template/app/modules/chart/utils/num_ext.dart';

import '../model/volume_model.dart';
import '../utils/number_util.dart';
import '../views/chart_style.dart';
import 'base_chart_renderer.dart';

///成交量渲染器
class VolRenderer extends BaseChartRenderer<VolumeModel> {
  ///成交量柱子的宽度
  late double mVolWidth;

  ///图表样式
  final ChartStyle chartStyle;

  ///图表颜色
  final ChartColors chartColors;
  VolRenderer(
    Rect mainRect, //图表尺寸
    double maxValue, //最大值
    double minValue, //最小值
    double topPadding, //顶部内间距
    int fixedLength, //固定价格精确度长度
    this.chartStyle, //图表样式
    this.chartColors, //图表颜色
  ) : super(
        chartRect: mainRect,
        maxValue: maxValue,
        minValue: minValue,
        topPadding: topPadding,
        fixedLength: fixedLength,
        gridColor: chartColors.gridColor,
      ) {
    mVolWidth = chartStyle.volWidth;
  }

  ///绘制网格
  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  ///绘制两个点之间的成交量柱状图和平均线
  @override
  void drawChart(
    VolumeModel lastPoint,
    VolumeModel curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    //计算柱状图绘制范围
    //r：柱子的半宽度。
    //top：当前成交量在 Y 坐标上的转换位置。
    //bottom：底部始终为 chartRect.bottom，即图表底边。
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;

    //绘制成交量柱子
    //如果当前成交量不为零，绘制一根竖向的矩形柱子
    //判断涨跌（close > open）来设置颜色（上涨用 upColor，下跌用 dnColor）
    if (curPoint.vol != 0) {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, top, curX + r, bottom),
        chartPaint
          ..color =
              curPoint.close > curPoint.open
                  ? chartColors.upColor
                  : chartColors.dnColor,
      );
    }

    //绘制 MA5 和 MA10 线条
    //分别判断 MA5 和 MA10 是否为非零，若是，则调用 drawLine 画出平均成交量曲线
    if (lastPoint.MA5Volume != 0) {
      drawLine(
        lastPoint.MA5Volume,
        curPoint.MA5Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma5Color,
      );
    }

    if (lastPoint.MA10Volume != 0) {
      drawLine(
        lastPoint.MA10Volume,
        curPoint.MA10Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma10Color,
      );
    }
  }

  ///成交量图的顶部绘制文字信息（如 VOL、MA5、MA10）
  @override
  void drawText(Canvas canvas, VolumeModel data, double x) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
          //交易量
          text: "VOL:${NumberUtil.format(data.vol)}    ",
          style: getTextStyle(chartColors.volColor),
        ),
        if (data.MA5Volume.notNullOrZero)
          //MA5
          TextSpan(
            text: "MA5:${NumberUtil.format(data.MA5Volume!)}    ",
            style: getTextStyle(chartColors.ma5Color),
          ),
        if (data.MA10Volume.notNullOrZero)
          //MA10
          TextSpan(
            text: "MA10:${NumberUtil.format(data.MA10Volume!)}    ",
            style: getTextStyle(chartColors.ma10Color),
          ),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  ///成交量图（Volume 图）的右上角绘制最大成交量数值
  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextSpan span = TextSpan(
      text: "${NumberUtil.format(maxValue)}",
      style: textStyle,
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(chartRect.width - tp.width, chartRect.top - topPadding),
    );
  }

  ///成交量数值 value 转换为在图表中对应的 Y 坐标位置
  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;
}
