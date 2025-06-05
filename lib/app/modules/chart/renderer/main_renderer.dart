import 'package:flutter/cupertino.dart';
import 'package:project_template/app/modules/chart/model/candle_model.dart';

import '../views/chart_style.dart';
import '../views/k_chart_widget.dart';
import 'base_chart_renderer.dart';

enum VerticalTextAlignment { left, right }

///趋势线
///当前主图区域的最大值（通常是价格的最高值）
double? trendLineMax;

///Y 轴缩放比例
double? trendLineScale;

///Y 轴绘图区域顶部的偏移
double? trendLineContentRec;

///绘制主图蜡烛和折线渲染器
class MainRenderer extends BaseChartRenderer<CandleModel> {
  ///蜡烛宽度
  late double mCandleWidth;

  ///蜡烛中间线的宽度
  late double mCandleLineWidth;

  ///当前主图状态，支持 MA、BOLL、NONE
  MainState state;

  ///是否为折线图模式
  bool isLine;

  ///绘制的内容区域
  late Rect _contentRect;

  ///绘图区域（上下留白）
  double _contentPadding = 5.0;

  ///均线周期列表（MA）
  List<int> maDayList;

  ///图表样式
  final ChartStyle chartStyle;

  ///图表颜色
  final ChartColors chartColors;

  /// 线条描边宽度
  final double mLineStrokeWidth = 1.0;

  ///横向缩放比
  double scaleX;

  ///线画笔
  late Paint mLinePaint;

  ///价格显示方向
  final VerticalTextAlignment verticalTextAlignment;
  MainRenderer(
    Rect mainRect, //图表尺寸
    double maxValue, //最大值
    double minValue, //最小值
    double topPadding, //顶部内间距
    this.state, //当前主图状态，支持 MA、BOLL、NONE
    this.isLine, //是否为折线图模式
    int fixedLength, //固定价格精确度长度
    this.chartStyle, //图表样式
    this.chartColors, //图表颜色
    this.scaleX, //横向缩放比
    this.verticalTextAlignment, [
    this.maDayList = const [5, 10, 20], //均线周期列表（MA）
  ]) : super(
         chartRect: mainRect, //图表尺寸
         maxValue: maxValue, //最大值
         minValue: minValue, //最小值
         topPadding: topPadding, //顶部内间距
         fixedLength: fixedLength, //固定价格精确度长度
         gridColor: chartColors.gridColor,
       ) {
    mCandleWidth = chartStyle.candleWidth;
    mCandleLineWidth = chartStyle.candleLineWidth;

    mLinePaint =
        Paint()
          ..isAntiAlias =
              true //抗锯齿，使线条平滑
          ..style =
              PaintingStyle
                  .stroke //只绘制线条，不填充
          ..strokeWidth =
              mLineStrokeWidth //线条宽度
          ..color = chartColors.kLineColor; //线条颜色

    _contentRect = Rect.fromLTRB(
      chartRect.left,
      chartRect.top + _contentPadding,
      chartRect.right,
      chartRect.bottom - _contentPadding,
    );

    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  ///画网格线
  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    //    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i + topPadding),
        Offset(chartRect.width, rowSpace * i + topPadding),
        gridPaint,
      );
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, topPadding / 3),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  ///顶部均线/布林线文本字符串渲染
  @override
  void drawText(Canvas canvas, CandleModel data, double x) {
    if (isLine == true) return;
    TextSpan? span;

    ///均线文本显示
    if (state == MainState.MA) {
      span = TextSpan(children: _createMATextSpan(data));
    } else if (state == MainState.BOLL) {
      ///布林线文本显示
      span = TextSpan(
        children: [
          if (data.up != 0)
            TextSpan(
              text: "BOLL:${format(data.mb)}    ",
              style: getTextStyle(this.chartColors.ma5Color),
            ),
          if (data.mb != 0)
            TextSpan(
              text: "UB:${format(data.up)}    ",
              style: getTextStyle(this.chartColors.ma10Color),
            ),
          if (data.dn != 0)
            TextSpan(
              text: "LB:${format(data.dn)}    ",
              style: getTextStyle(this.chartColors.ma30Color),
            ),
        ],
      );
    }

    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  ///创建MA的文本样式
  List<InlineSpan> _createMATextSpan(CandleModel data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        var item = TextSpan(
          text: "MA${maDayList[i]}:${format(data.maValueList![i])}    ",
          style: getTextStyle(chartColors.getMAColor(i)),
        );
        result.add(item);
      }
    }
    return result;
  }

  ///绘制图表主区域的图形内容（蜡烛图或折线图）
  ///lastPoint  上一个数据点（用于连线）
  ///curPoint  当前数据点用于绘制当前蜡烛或线段）
  ///lastX  上一个数据点的 X 坐标
  ///curX  当前数据点的 X 坐标
  ///size  画布大小
  ///canvas  画布对象
  @override
  void drawChart(
    CandleModel lastPoint,
    CandleModel curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    if (isLine) {
      ///绘制折线图
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else {
      ///绘制蜡烛图
      drawCandle(curPoint, canvas, curX);
      if (state == MainState.MA) {
        ///绘制均线
        drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.BOLL) {
        ///绘制布林线
        drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
      }
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint =
      Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

  ///画折线
  drawPolyline(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    //用于绘制线的主路径，只初始化一次
    mLinePath ??= Path();
    //若两个点重合，设为 0，避免曲线失效
    if (lastX == curX) lastX = 0; //起点位置填充

    //绘制曲线路径
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );

    //创建渐变阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [chartColors.lineFillColor, chartColors.lineFillInsideColor],
    ).createShader(
      Rect.fromLTRB(
        chartRect.left,
        chartRect.top,
        chartRect.right,
        chartRect.bottom,
      ),
    );
    mLineFillPaint.shader = mLineFillShader;

    //构建阴影区域路径
    //路径形状像一个“围起来的波浪”，下方阴影区就是通过这个闭合路径绘制出来的。
    mLineFillPath ??= Path();
    ////底部起点
    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    ////上升到价格
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );
    //回到底部闭合
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    //绘制阴影与折线
    //先绘制阴影，再画折线。注意线宽根据缩放 scaleX 进行动态缩放限制在 0.1 - 1.0 范围内。
    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();
    canvas.drawPath(
      mLinePath!,
      mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0),
    );
    mLinePath!.reset();
  }

  /// K 线图上绘制 单个蜡烛柱（K线），包括实体和上下影线
  void drawCandle(CandleModel curPoint, Canvas canvas, double curX) {
    //将价格值映射到实际 canvas 坐标系统中的 Y 值，越高的价格对应越小的 Y。
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);

    //计算蜡烛实体的宽度
    double r = mCandleWidth / 2; //r: 实体矩形的一半宽度。
    double lineR = mCandleLineWidth / 2; //lineR: 上下影线的宽度。

    //绘制上涨（绿色）或下跌（红色）K线
    //上涨：open >= close
    if (open >= close) {
      // •	实体: 从 close 到 open 绿色矩形。
      // •	影线: 从 high 到 low 的绿色细线。
      // •	宽度不够时强制拉宽以保证视觉可见。
      // 实体高度>= CandleLineWidth
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }
      chartPaint.color = chartColors.upColor;
      canvas.drawRect(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        chartPaint, //, chartPaint..style = PaintingStyle.stroke 绘制空心蜡烛柱（通常用于上涨趋势）
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
      //下跌：close > open
    } else if (close > open) {
      // •	实体: 从 open 到 close 的红色矩形。
      // •	影线: 同样从 high 到 low，也是红色。
      // 实体高度>= CandleLineWidth
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }
      chartPaint.color = chartColors.dnColor;
      canvas.drawRect(
        Rect.fromLTRB(curX - r, open, curX + r, close),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
    }
  }

  ///绘制均线（MA，Moving Average）曲线段
  ///	•	lastPoint, curPoint: 前一个和当前的 CandleEntity 数据点，包含 maValueList（MA5, MA10, MA30等）。
  /// 	•	canvas: 当前图层画布。
  /// 	•	lastX, curX: 对应两个数据点在画布上的横坐标。
  void drawMaLine(
    CandleModel lastPoint,
    CandleModel curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    //最多只绘制前 3 条均线（通常是 MA5、MA10、MA30）
    for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      //检查前一个数据点该 MA 值是否有效（非 0），避免绘制断线或不必要的线段。
      if (lastPoint.maValueList?[i] != 0) {
        //调用基类方法 drawLine() 画出该 MA 曲线段
        drawLine(
          lastPoint.maValueList?[i],
          curPoint.maValueList?[i],
          canvas,
          lastX,
          curX,
          chartColors.getMAColor(i),
        );
      }
    }
  }

  /// 绘制布林带（BOLL）三条线
  void drawBollLine(
    CandleModel lastPoint,
    CandleModel curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    //画 上轨线
    if (lastPoint.up != 0) {
      drawLine(
        lastPoint.up,
        curPoint.up,
        canvas,
        lastX,
        curX,
        this.chartColors.ma10Color,
      );
    }
    //	画 中轨线
    if (lastPoint.mb != 0) {
      drawLine(
        lastPoint.mb,
        curPoint.mb,
        canvas,
        lastX,
        curX,
        this.chartColors.ma5Color,
      );
    }
    //画 下轨线
    if (lastPoint.dn != 0) {
      drawLine(
        lastPoint.dn,
        curPoint.dn,
        canvas,
        lastX,
        curX,
        this.chartColors.ma30Color,
      );
    }
  }

  ///竖排 K线图 的左侧或右侧绘制价格刻度文字
  ///canvas Flutter 的 Canvas 绘图对象
  /// textStyle  绘制文字的样式
  /// gridRows Y 轴网格行数，用于决定多少条水平参考线
  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    ///计算每行高度间隔
    double rowSpace = chartRect.height / gridRows;

    ///循环绘制每一行对应的 Y 轴价格文本
    for (var i = 0; i <= gridRows; ++i) {
      ///根据行号计算对应的值（从上往下）
      double value = (gridRows - i) * rowSpace / scaleY + minValue;

      ///创建 TextSpan 和 TextPainter 绘制文
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);

      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double offsetX;

      ///根据 VerticalTextAlignment 决定左对齐或右对齐的位置
      switch (verticalTextAlignment) {
        case VerticalTextAlignment.left:
          offsetX = 0;
          break;
        case VerticalTextAlignment.right:
          offsetX = chartRect.width - tp.width;
          break;
      }

      ///顶部刻度固定绘制在 topPadding
      ///其余刻度按 rowSpace * i - tp.height + topPadding 调整，使文字垂直居中对齐网格线
      if (i == 0) {
        tp.paint(canvas, Offset(offsetX, topPadding));
      } else {
        tp.paint(
          canvas,
          Offset(offsetX, rowSpace * i - tp.height + topPadding),
        );
      }
    }
  }

  @override
  double getY(double y) {
    //For TrendLine
    updateTrendLineData();
    return (maxValue - y) * scaleY + _contentRect.top;
  }

  ///更新趋势线数据
  void updateTrendLineData() {
    trendLineMax = maxValue;
    trendLineScale = scaleY;
    trendLineContentRec = _contentRect.top;
  }
}
