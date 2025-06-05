import 'package:flutter/material.dart';
import 'package:project_template/app/modules/chart/model/macd_model.dart';

import '../views/chart_style.dart';
import '../views/k_chart_widget.dart';
import 'base_chart_renderer.dart';

///副图渲染器
class SecondaryRenderer extends BaseChartRenderer<MACDModel> {
  ///副图MACD柱子的宽度
  late double mMACDWidth;

  ///副图类型
  SecondaryState state;

  ///图表样式
  final ChartStyle chartStyle;

  ///图表颜色
  final ChartColors chartColors;

  SecondaryRenderer(
    Rect mainRect, //图表尺寸
    double maxValue, //最大值
    double minValue, //最小值
    double topPadding, //顶部内间距
    this.state, //副图类型
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
    mMACDWidth = chartStyle.macdWidth;
  }

  ///绘制网格
  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(
      Offset(0, chartRect.top),
      Offset(chartRect.width, chartRect.top),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  ///绘制副图图形（MACD、KDJ、RSI、WR、CCI）
  ///	•	lastPoint / curPoint: 上一个和当前的数据点。
  /// 	•	lastX / curX: 上一个和当前数据点的 x 坐标。
  /// 	•	canvas: 画布，用于绘图。
  /// 	•	state: 当前副图状态，如 MACD、KDJ 等。
  @override
  void drawChart(
    MACDModel lastPoint,
    MACDModel curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        //绘制 K、D、J 三条线。
        drawLine(
          lastPoint.k,
          curPoint.k,
          canvas,
          lastX,
          curX,
          chartColors.kColor,
        );
        drawLine(
          lastPoint.d,
          curPoint.d,
          canvas,
          lastX,
          curX,
          chartColors.dColor,
        );
        drawLine(
          lastPoint.j,
          curPoint.j,
          canvas,
          lastX,
          curX,
          chartColors.jColor,
        );
        break;
      case SecondaryState.RSI:
        //绘制 RSI 指标曲线
        drawLine(
          lastPoint.rsi,
          curPoint.rsi,
          canvas,
          lastX,
          curX,
          chartColors.rsiColor,
        );
        break;
      case SecondaryState.WR:
        //绘制 WR 指标曲线
        drawLine(
          lastPoint.r,
          curPoint.r,
          canvas,
          lastX,
          curX,
          chartColors.rsiColor,
        );
        break;
      case SecondaryState.CCI:
        //绘制 CCI 指标曲线
        drawLine(
          lastPoint.cci,
          curPoint.cci,
          canvas,
          lastX,
          curX,
          chartColors.rsiColor,
        );
        break;
      default:
        break;
    }
  }

  ///绘制MACD指标柱子
  void drawMACD(
    MACDModel curPoint,
    Canvas canvas,
    double curX,
    MACDModel lastPoint,
    double lastX,
  ) {
    final macd = curPoint.macd ?? 0;
    double macdY = getY(macd); // MACD 对应的 Y 轴位置
    double r = mMACDWidth / 2; // 零轴位置
    double zeroy = getY(0); // 柱子的半宽度
    //MACD > 0：上涨 → 用上涨颜色画从 macdY 到 zeroy 的柱
    if (macd > 0) {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
        chartPaint..color = chartColors.upColor,
      );
      //MACD < 0：下跌 → 用下跌颜色画从 zeroy 到 macdY 的柱
    } else {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
        chartPaint..color = chartColors.dnColor,
      );
    }
    //如果前一个数据点有值，则画线连接 DIF / DEA 两个点
    if (lastPoint.dif != 0) {
      drawLine(
        lastPoint.dif,
        curPoint.dif,
        canvas,
        lastX,
        curX,
        chartColors.difColor,
      );
    }
    if (lastPoint.dea != 0) {
      drawLine(
        lastPoint.dea,
        curPoint.dea,
        canvas,
        lastX,
        curX,
        chartColors.deaColor,
      );
    }
  }

  ///图表左上方绘制指标名称与实时数据值
  ///MACD 指标 或者 KDJ 指标
  @override
  void drawText(Canvas canvas, MACDModel data, double x) {
    List<TextSpan>? children;
    switch (state) {
      //MACD 指标数据
      case SecondaryState.MACD:
        //显示 MACD 参数和三条线：MACD, DIF, DEA
        children = [
          TextSpan(
            text: "MACD(12,26,9)    ",
            style: getTextStyle(chartColors.defaultTextColor),
          ),
          if (data.macd != 0)
            TextSpan(
              text: "MACD:${format(data.macd)}    ",
              style: getTextStyle(chartColors.macdColor),
            ),
          if (data.dif != 0)
            TextSpan(
              text: "DIF:${format(data.dif)}    ",
              style: getTextStyle(chartColors.difColor),
            ),
          if (data.dea != 0)
            TextSpan(
              text: "DEA:${format(data.dea)}    ",
              style: getTextStyle(chartColors.deaColor),
            ),
        ];
        break;
      // KDJ 指标数据
      case SecondaryState.KDJ:
        children = [
          TextSpan(
            text: "KDJ(9,1,3)    ",
            style: getTextStyle(chartColors.defaultTextColor),
          ),
          if (data.macd != 0)
            TextSpan(
              text: "K:${format(data.k)}    ",
              style: getTextStyle(chartColors.kColor),
            ),
          if (data.dif != 0)
            TextSpan(
              text: "D:${format(data.d)}    ",
              style: getTextStyle(chartColors.dColor),
            ),
          if (data.dea != 0)
            TextSpan(
              text: "J:${format(data.j)}    ",
              style: getTextStyle(chartColors.jColor),
            ),
        ];
        break;
      //RSI指标数据
      case SecondaryState.RSI:
        children = [
          TextSpan(
            text: "RSI(14):${format(data.rsi)}    ",
            style: getTextStyle(chartColors.rsiColor),
          ),
        ];
        break;
      //WR指标数据
      case SecondaryState.WR:
        children = [
          TextSpan(
            text: "WR(14):${format(data.r)}    ",
            style: getTextStyle(chartColors.rsiColor),
          ),
        ];
        break;
      //CCI指标数据
      case SecondaryState.CCI:
        children = [
          TextSpan(
            text: "CCI(14):${format(data.cci)}    ",
            style: getTextStyle(chartColors.rsiColor),
          ),
        ];
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(
      text: TextSpan(children: children ?? []),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  ///绘制副图（如 MACD、KDJ 等）坐标轴的最大值和最小值文本 右侧
  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
      text: TextSpan(text: "${format(maxValue)}", style: textStyle),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    TextPainter minTp = TextPainter(
      text: TextSpan(text: "${format(minValue)}", style: textStyle),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();

    maxTp.paint(
      canvas,
      Offset(chartRect.width - maxTp.width, chartRect.top - topPadding),
    );
    minTp.paint(
      canvas,
      Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height),
    );
  }
}
