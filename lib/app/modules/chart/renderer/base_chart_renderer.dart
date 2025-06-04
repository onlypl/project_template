import 'package:flutter/material.dart';

///基础图表渲染器
abstract class BaseChartRenderer<T> {
  ///最大值和最小值
  double maxValue, minValue;

  ///y缩放比例
  late double scaleY;

  ///顶部内间距
  double topPadding;

  ///图表尺寸
  Rect chartRect;

  ///固定价格精确度长度
  int fixedLength;

  ///图表的画笔
  Paint chartPaint =
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..strokeWidth = 1.0
        ..color = Colors.red;

  ///网格的画笔
  Paint gridPaint =
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..strokeWidth = 0.5
        ..color = Color(0xff4c5c74);

  BaseChartRenderer({
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.fixedLength,
    required Color gridColor,
  }) {
    ///最大值和最小值相等 scaleY = height / 0 会导致异常（除以零）
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
    gridPaint.color = gridColor;
    // print("maxValue=====" + maxValue.toString() + "====minValue===" + minValue.toString() + "==scaleY==" + scaleY.toString());
  }

  ///实际数值y映射屏幕上的像素坐标 Y 值   值 → 坐标
  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  ///格式化
  String format(double? n) {
    if (n == null || n.isNaN) {
      return "0.00";
    } else {
      return n.toStringAsFixed(fixedLength);
    }
  }

  ///画网格
  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  ///画文本
  void drawText(Canvas canvas, T data, double x);

  ///画垂直方向文本
  void drawVerticalText(canvas, textStyle, int gridRows);

  ///画图表
  void drawChart(
    T lastPoint,
    T curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  );

  ///画线条
  void drawLine(
    double? lastPrice,
    double? curPrice,
    Canvas canvas,
    double lastX,
    double curX,
    Color color,
  ) {
    if (lastPrice == null || curPrice == null) {
      return;
    }
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    //print("lastX-----==" + lastX.toString() + "==lastY==" + lastY.toString() + "==curX==" + curX.toString() + "==curY==" + curY.toString());
    canvas.drawLine(
      Offset(lastX, lastY),
      Offset(curX, curY),
      chartPaint..color = color,
    );
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}
