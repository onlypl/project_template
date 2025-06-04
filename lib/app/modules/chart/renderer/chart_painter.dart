import 'dart:ui';

import 'package:project_template/app/modules/chart/model/k_line_model.dart';
import 'package:project_template/app/modules/chart/renderer/base_chart_painter.dart';

///------绘制图表画布
///趋势线类
class TrendLine {
  ///趋势线起点坐标
  final Offset p1;

  ///趋势线终点坐标
  final Offset p2;

  ///图表高度
  final double maxHeight;

  ///缩放比例
  final double scale;

  TrendLine(this.p1, this.p2, this.maxHeight, this.scale);
}

class ChartPainter extends BaseChartPainter {
  ChartPainter(
    super.chartStyle,
    super.datas, {
    required super.scaleX,
    required super.scrollX,
    required super.isLongPress,
    required super.selectX,
    required super.xFrontPadding,
  });

  @override
  void drawBg(Canvas canvas, Size size) {
    // TODO: implement drawBg
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    // TODO: implement drawChart
  }

  @override
  void drawCrossLine(Canvas canvas, Size size) {
    // TODO: implement drawCrossLine
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    // TODO: implement drawCrossLineText
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    // TODO: implement drawDate
  }

  @override
  void drawGrid(canvas) {
    // TODO: implement drawGrid
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    // TODO: implement drawMaxAndMin
  }

  @override
  void drawNowPrice(Canvas canvas) {
    // TODO: implement drawNowPrice
  }

  @override
  void drawText(Canvas canvas, KLineModel data, double x) {
    // TODO: implement drawText
  }

  @override
  void drawVerticalText(canvas) {
    // TODO: implement drawVerticalText
  }

  @override
  void initChartRenderer() {
    // TODO: implement initChartRenderer
  }
}
