import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_template/app/modules/chart/model/k_line_model.dart';
import 'package:project_template/app/modules/chart/renderer/base_chart_painter.dart';
import 'package:project_template/app/modules/chart/renderer/secondary_renderer.dart';
import 'package:project_template/app/modules/chart/renderer/vol_renderer.dart';

import '../model/info_window_model.dart';
import '../utils/date_format_util.dart';
import '../utils/number_util.dart';
import '../views/chart_style.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';

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

double? trendLineX; //趋势线x坐标

double getTrendLineX() {
  return trendLineX ?? 0;
}

class ChartPainter extends BaseChartPainter {
  ///图表样式
  final ChartStyle chartStyle;

  ///图表颜色配置
  final ChartColors chartColors;

  ///趋势线数组
  final List<TrendLine> lines;

  ///是否显示趋势线
  final bool isTrendLine;

  ///是否正在录制趋势线坐标
  bool isRecordingCord = false;

  ///趋势线 长按选中点Y坐标
  final double selectY;

  ///最大可横向滚动范围
  static get maxScrollX => BaseChartPainter.maxScrollX;

  ///主图渲染器
  late BaseChartRenderer mMainRenderer;

  ///成交量渲染器 和 副图渲染器
  BaseChartRenderer? mVolRenderer, mSecondaryRenderer;

  ///Stream流 包含某个 K 线数据点的详细信息及是否在左侧
  ///sink 变量允许你在图表绘制过程中向外部组件（如弹出的信息框、tooltip）推送数据
  StreamSink<InfoWindowModel?>? sink;

  ///上轨线/下轨线  颜色
  Color? upColor, dnColor;

  ///5日、10日、30日均线
  Color? ma5Color, ma10Color, ma30Color;

  ///成交量图颜色
  Color? volColor;

  ///macdColor MACD 柱状图（Bar）颜色
  // difColor  DIF MACD 的短期 EMA 与长期 EMA 差值线
  // deaColor  DEA  DIF 的平滑平均线（又称 Signal）
  // jColor J（from KDJ） KDJ 指标中的快速线 J 的颜色
  Color? macdColor, difColor, deaColor, jColor;

  ///固定价格精确度
  int fixedLength;

  ///均线周期列表（MA）
  List<int> maDayList;

  ///十字线选中点的圆点 选中信息框（info window）的边框 当前价格线”或右侧最新价格提示
  late Paint selectPointPaint, selectorBorderPaint, nowPricePaint;

  ///是否隐藏网格
  final bool hideGrid;

  ///显示当前价
  final bool showNowPrice;

  ///垂直价格方向 左/右
  final VerticalTextAlignment verticalTextAlignment;
  ChartPainter(
    this.chartStyle, //图表样式
    this.chartColors, { //图表颜色配置
    required this.lines, //趋势线数组
    required this.isTrendLine, //是否显示趋势线
    required this.selectY, //趋势线 长按选中点Y坐标
    required this.verticalTextAlignment, //垂直价格方向 左/右
    required datas, //数据源
    required scaleX, //缩放比例
    required scrollX, //横向滚动的偏移量
    required isLongPress, //是否是长按状态
    required selectX, //用户长按或点击的横向位置
    required xFrontPadding, //X轴内间距
    isOnTap, //是否是点击状态
    isTapShowInfoDialog, //是否是点击显示信息弹窗
    mainState, //主图类型
    volHidden, //成交量是否隐藏
    secondaryState, //副图类型
    this.sink,
    bool isLine = false, //是否是折线图
    this.hideGrid = false, //隐藏网格
    this.showNowPrice = true, //显示当前价
    this.fixedLength = 2, //价格固定精确度
    this.maDayList = const [5, 10, 20], //均线周期列表（MA）
  }) : super(
         chartStyle,
         datas: datas,
         scaleX: scaleX,
         scrollX: scrollX,
         isLongPress: isLongPress,
         isOnTap: isOnTap,
         isTapShowInfoDialog: isTapShowInfoDialog,
         selectX: selectX,
         mainState: mainState,
         volHidden: volHidden,
         secondaryState: secondaryState,
         xFrontPadding: xFrontPadding,
         isLine: isLine,
       ) {
    ///初始化画笔
    selectPointPaint =
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 0.5
          ..color = chartColors.selectFillColor;

    selectorBorderPaint =
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke
          ..color = chartColors.selectBorderColor;

    nowPricePaint =
        Paint()
          ..strokeWidth = chartStyle.nowPriceLineWidth
          ..isAntiAlias = true;
  }

  ///初始化图表渲染器
  @override
  void initChartRenderer() {
    ///根据当前 K 线数据（datas）的第一条数据，动态计算价格字段的小数精度（即保留几位小数）
    if (datas != null && datas!.isNotEmpty) {
      var t = datas![0]; // 取第一条数据
      fixedLength = NumberUtil.getMaxDecimalLength(
        t.open,
        t.close,
        t.high,
        t.low,
      );
    }

    ///初始化主图渲染器 MainRenderer，主要用于绘制主图 K 线（蜡烛图或折线图）部分
    ///mMainRect  主图区域的绘图矩形
    /// mMainMaxValue / mMainMinValue 当前可视区域内主图的最大/最小值
    /// mTopPadding 主图顶部留白，用于不让图线贴近顶边
    /// mainState 主图状态，决定绘制 K 线、MA、BOLL 等类型
    /// isLine 是否使用折线图模式，true 为折线图，false 为蜡烛图
    /// fixedLength 数值小数位精度（由数据动态决定）
    /// chartStyle 样式配置，例如线宽、间距等
    /// chartColors 颜色配置，例如涨跌色、均线色等
    mMainRenderer = MainRenderer(
      mMainRect, //主图区域的绘图矩形
      mMainMaxValue, //当前可视区域内主图的最大
      mMainMinValue, //当前可视区域内主图的最小值
      mTopPadding, //主图顶部留白，用于不让图线贴近顶边
      mainState, //主图状态，决定绘制 K 线、MA、BOLL 等类型
      isLine, //是否使用折线图模式，true 为折线图，false 为蜡烛图
      fixedLength, //数值小数位精度（由数据动态决定）
      chartStyle, //样式配置，例如线宽、间距等
      chartColors, //颜色配置，例如涨跌色、均线色等
      scaleX, //缩放比例
      verticalTextAlignment, //垂直价格方向 左/右
      maDayList, //均线周期列表（MA）
    );

    ///初始化成交量渲染器 VolRenderer，主要用于绘制成交量部分
    if (mVolRect != null) {
      mVolRenderer = VolRenderer(
        mVolRect!, //成交量区域的绘图矩形
        mVolMaxValue, //mVolMaxValue / mVolMinValue 当前可视区域内成交量的最大/最小值
        mVolMinValue,
        mChildPadding, //成交量区域内的留白，用于不让图线贴近顶边和底边
        fixedLength, //数值小数位精度（由数据动态决定）
        chartStyle, //样式配置，例如线宽、间距等
        chartColors, //颜色配置，例如涨跌色、均线色等
      );
    }

    ///初始化副图渲染器 SecondaryRenderer，主要用于绘制副图指标部分
    if (mSecondaryRect != null) {
      mSecondaryRenderer = SecondaryRenderer(
        mSecondaryRect!, //副图区域的绘图矩形
        mSecondaryMaxValue, //前可视区域内副图的最大值
        mSecondaryMinValue, //前可视区域内副图的最小值
        mChildPadding, //副图区域内的留白，用于不让图线贴近顶边和底边
        secondaryState, //副图状态，决定绘制指标类型
        fixedLength, //数值小数位精度（由数据动态决定）
        chartStyle, //样式配置，例如线宽、间距等
        chartColors, //颜色配置，例如涨跌色、均线色等
      );
    }
  }

  ///绘制背景
  @override
  void drawBg(Canvas canvas, Size size) {
    ///线性渐变背景
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: chartColors.bgColor,
    );

    ///主图区域的绘图矩形
    Rect mainRect = Rect.fromLTRB(
      0,
      0,
      mMainRect.width,
      mMainRect.height + mTopPadding,
    );
    canvas.drawRect(
      mainRect,
      mBgPaint..shader = mBgGradient.createShader(mainRect),
    );

    ///成交量区域的绘图矩形
    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(
        0,
        mVolRect!.top - mChildPadding,
        mVolRect!.width,
        mVolRect!.bottom,
      );
      canvas.drawRect(
        volRect,
        mBgPaint..shader = mBgGradient.createShader(volRect),
      );
    }

    ///副图区域的绘图矩形
    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(
        0,
        mSecondaryRect!.top - mChildPadding,
        mSecondaryRect!.width,
        mSecondaryRect!.bottom,
      );
      canvas.drawRect(
        secondaryRect,
        mBgPaint..shader = mBgGradient.createShader(secondaryRect),
      );
    }

    ///日期区域的绘图矩形
    Rect dateRect = Rect.fromLTRB(
      0,
      size.height - mBottomPadding,
      size.width,
      size.height,
    );
    canvas.drawRect(
      dateRect,
      mBgPaint..shader = mBgGradient.createShader(dateRect),
    );
  }

  ///绘制网格
  @override
  void drawGrid(canvas) {
    if (!hideGrid) {
      mMainRenderer.drawGrid(canvas, mGridRows, mGridColumns);
      mVolRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
      mSecondaryRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
    }
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    ///画布预处理
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);

    /// 绘制主图、成交量图、副图
    /// 遍历当前可视区域内的 K 线数据
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineModel? curPoint = datas?[i]; //获取当前索引 i 对应的数据点（实体）
      if (curPoint == null) continue; //容错处理：跳过无效或为空的数据
      //	•	获取上一个数据点，用于绘制连线
      // 	•	如果是第一条数据，避免越界，使用自身替代
      KLineModel lastPoint = i == 0 ? curPoint : datas![i - 1];
      //根据索引计算当前点在屏幕上的 x 坐标位置
      double curX = getX(i);
      //计算上一个数据点的横坐标，用于画线连接
      double lastX = i == 0 ? curX : getX(i - 1);
      //绘制主图
      mMainRenderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      //绘制成交量柱状图
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      //绘制技术指标
      mSecondaryRenderer?.drawChart(
        lastPoint,
        curPoint,
        lastX,
        curX,
        size,
        canvas,
      );
    }

    ///如果是按或点击显示详情数据，且当前不是趋势线模式（!isTrendLine）
    ///画交叉线
    if ((isLongPress == true || (isTapShowInfoDialog && isOnTap)) &&
        isTrendLine == false) {
      drawCrossLine(canvas, size);
    }

    ///是否绘制趋势线
    if (isTrendLine == true) drawTrendLines(canvas, size);
    canvas.restore();
  }

  ///画右边文本值
  @override
  void drawVerticalText(canvas) {
    var textStyle = getTextStyle(this.chartColors.defaultTextColor);
    if (!hideGrid) {
      mMainRenderer.drawVerticalText(canvas, textStyle, mGridRows);
    }
    mVolRenderer?.drawVerticalText(canvas, textStyle, mGridRows);
    mSecondaryRenderer?.drawVerticalText(canvas, textStyle, mGridRows);
  }

  ///在底部网格均分位置，绘制对应 K 线数据的时间标签（日期）
  @override
  void drawDate(Canvas canvas, Size size) {
    //如果没有数据，直接跳过绘制
    if (datas == null) return;
    //将画布宽度按列数均分，确定每一列之间的间隔
    double columnSpace = size.width / mGridColumns;
    //获取可视区域内绘制的起止 X 坐标范围，用于后续限制只绘制可见的时间标签
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double x = 0.0;
    double y = 0.0;
    //遍历列数，通过每列位置算出其对应的数据下标坐标（translateX 是逻辑坐标，和 scroll/scale 有关）。
    for (var i = 0; i <= mGridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);

      //如果该列在当前视图区域内，查找对应的 K 线数据下标并判空。
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        if (datas?[index] == null) continue;
        //获取格式化后的时间字符串并用 TextPainter 渲染
        TextPainter tp = getTextPainter(getDate(datas![index].time), null);
        //计算时间标签的位置，居中对齐列坐标
        y = size.height - (mBottomPadding - tp.height) / 2 - tp.height;
        x = columnSpace * i - tp.width / 2;
        // 保证标签不超出画布边界
        if (x < 0) x = 0;
        if (x > size.width - tp.width) x = size.width - tp.width;
        //在计算好的位置绘制时间标签
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  ///在长按或点击 K 线图时，绘制选中点（十字线交点）的价格和时间信息
  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    ///通过当前选中横坐标 selectX，计算选中的数据索引
    var index = calculateSelectedX(selectX);
    KLineModel point = getItem(index);

    ///绘制 Y 轴（价格）标签 Tooltip
    TextPainter tp = getTextPainter(point.close, chartColors.crossTextColor);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close); //将当前价格转换为图表上的 Y 坐标
    double x;
    bool isLeft = false;

    /// 绘制在左侧（十字线在左）
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();

      ///绘制价格框及其边框 + 价格文字。
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      /// 绘制在右侧（十字线在右）
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();

      ///绘制价格框及其边框 + 价格文字。
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    ///绘制 X 轴（时间）标签 Tooltip
    TextPainter dateTp = getTextPainter(
      getDate(point.time),
      chartColors.crossTextColor,
    );
    textWidth = dateTp.width;
    r = textHeight / 2;
    //确定时间标签的位置在图表底部
    x = translateXtoX(getX(index));
    y = size.height - mBottomPadding;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;

    ///绘制背景 + 边框 + 时间文字。
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectPointPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectorBorderPaint,
    );

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));

    ///长按显示这条数据详情
    ///将当前选中点信息（价格、时间、位置方向）推送出去，用于外部组件展示详细信息窗口（InfoWindow）
    sink?.add(InfoWindowModel(point, isLeft: isLeft));
  }

  ///在主、副图上显示数据信息的绘制函数，通常在选中某根 K 线（如长按或点击）时触发
  @override
  void drawText(Canvas canvas, KLineModel data, double x) {
    ///长按显示按中的数据
    ///判断是否为长按或点击查看详情模式：
    ///•	如果满足条件，从 selectX 位置计算选中的数据索引，获取对应 KLineEntity 数据。
    ///•	用该数据覆盖 data，用于后续文字绘制。
    if (isLongPress || (isTapShowInfoDialog && isOnTap)) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }

    ///松开显示最后一条数据
    ///调用各区域的 renderer，分别绘制：
    /// •	主图数据（如 MA、BOLL 指标等）
    /// •	成交量图数据
    /// •	副图数据（如 MACD、KDJ 等）
    mMainRenderer.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  ///在 K 线图主图区域绘制“最高价”和“最低价”的标记线及数值标签
  @override
  void drawMaxAndMin(Canvas canvas) {
    ///当前是否是“折线图”模式，如果是就不绘制最高/最低点（逻辑退出）
    if (isLine == true) return;

    ///水平线的长度
    double lineSize = 20;

    ///水平线与文字之间的间距
    double lineToTextOffset = 5;

    Paint linePaint =
        Paint()
          ..strokeWidth = 1
          ..color = chartColors.minColor;

    ///绘制最大值和最小值
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);

    ///计算最低价的位置
    if (x < mWidth / 2) {
      /// 绘制在右侧
      TextPainter tp = getTextPainter(
        mMainLowMinValue.toStringAsFixed(fixedLength),
        chartColors.minColor,
      );

      ///绘制水平线 + 文本标签
      canvas.drawLine(Offset(x, y), Offset(x + lineSize, y), linePaint);
      tp.paint(
        canvas,
        Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
      );
    } else {
      /// 绘制在左侧
      TextPainter tp = getTextPainter(
        mMainLowMinValue.toStringAsFixed(fixedLength),
        chartColors.minColor,
      );

      ///绘制水平线 + 文本标签
      canvas.drawLine(Offset(x, y), Offset(x - lineSize, y), linePaint);
      tp.paint(
        canvas,
        Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
      );
    }

    ///计算最高价的位置
    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);

    ///判断是在画布的左侧还是右侧，决定绘制在文字的左右
    if (x < mWidth / 2) {
      /// 绘制在右侧
      TextPainter tp = getTextPainter(
        mMainHighMaxValue.toStringAsFixed(fixedLength),
        chartColors.maxColor,
      );

      ///绘制水平线 + 文本标签
      canvas.drawLine(Offset(x, y), Offset(x + lineSize, y), linePaint);
      tp.paint(
        canvas,
        Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
      );
    } else {
      ///绘制在左侧
      TextPainter tp = getTextPainter(
        mMainHighMaxValue.toStringAsFixed(fixedLength),
        chartColors.maxColor,
      );

      ///绘制水平线 + 文本标签
      canvas.drawLine(Offset(x, y), Offset(x - lineSize, y), linePaint);
      tp.paint(
        canvas,
        Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
      );
    }
  }

  ///绘制当前最新价格横线与价格文本标签
  @override
  void drawNowPrice(Canvas canvas) {
    ///确保当前启用了 showNowPrice 并且数据不为空
    if (!showNowPrice || datas == null) {
      return;
    }

    /// 获取 最新数据点的收盘价
    ///	将其转为画布中对应的 y 坐标
    double value = datas!.last.close;
    double y = getMainY(value);

    ///视图展示区域边界值绘制
    if (y > getMainY(mMainLowMinValue)) {
      y = getMainY(mMainLowMinValue);
    }

    if (y < getMainY(mMainHighMaxValue)) {
      y = getMainY(mMainHighMaxValue);
    }

    ///如果涨了（收盘价 ≥ 开盘价）→ 使用上涨颜色
    ///如果跌了 → 使用下跌颜色
    nowPricePaint.color =
        value >= datas!.last.open
            ? chartColors.nowPriceUpColor
            : chartColors.nowPriceDnColor;

    ///绘制虚线（横向间隔线）
    double startX = 0;
    final max = -mTranslateX + mWidth / scaleX;
    final space = chartStyle.nowPriceLineSpan + chartStyle.nowPriceLineLength;

    ///通过 while 循环在横向重复绘制虚线，形成“价格参考线”的效果
    while (startX < max) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartStyle.nowPriceLineLength, y),
        nowPricePaint,
      );
      startX += space;
    }

    ///绘制价格标签文本 + 背景
    ///根据 verticalTextAlignment 决定文本标签的位置

    TextPainter tp = getTextPainter(
      value.toStringAsFixed(fixedLength),
      chartColors.nowPriceTextColor,
    );

    double offsetX;
    switch (verticalTextAlignment) {
      case VerticalTextAlignment.left:
        offsetX = 0;
        break;
      case VerticalTextAlignment.right:
        offsetX = mWidth - tp.width;
        break;
    }

    double top = y - tp.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(offsetX, top, offsetX + tp.width, top + tp.height),
      nowPricePaint,
    );
    tp.paint(canvas, Offset(offsetX, top));
  }

  ///趋势线
  ///     获取当前选中的 X 坐标位置
  /// 	•	绘制十字竖线（代表某一时刻）
  /// 	•	绘制横线（表示某价格）
  /// 	•	绘制一个椭圆标记交点
  /// 	•	绘制所有用户绘制的趋势线（TrendLine）
  void drawTrendLines(Canvas canvas, Size size) {
    {
      ///当前选中的数据索引
      var index = calculateSelectedX(selectX);
      Paint paintY =
          Paint()
            ..color = Colors.orange
            ..strokeWidth = 1
            ..isAntiAlias = true;

      ///对应 K 线图中蜡烛图的 X 轴位置
      double x = getX(index);
      trendLineX = x;

      ///用户点选的位置，y 为竖线和横线交点的 Y 坐标
      double y = selectY;
      // getMainY(point.close);

      /// k线图竖线（十字线）
      canvas.drawLine(
        Offset(x, mTopPadding),
        Offset(x, size.height - mBottomPadding),
        paintY,
      );
      Paint paintX =
          Paint()
            ..color = Colors.orangeAccent
            ..strokeWidth = 1
            ..isAntiAlias = true;
      Paint paint =
          Paint()
            ..color = Colors.orange
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      ///画横线（十字线）
      canvas.drawLine(
        Offset(-mTranslateX, y),
        Offset(-mTranslateX + mWidth / scaleX, y),
        paintX,
      );
      if (scaleX >= 1) {
        ///画圆形标记交点
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            height: 15.0 * scaleX,
            width: 15.0,
          ),
          paint,
        );
      } else {
        ///画圆形标记交点
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            height: 10.0,
            width: 10.0 / scaleX,
          ),
          paint,
        );
      }

      ///画用户定义的趋势线（lines）
      if (lines.length >= 1) {
        lines.forEach((element) {
          var y1 = -((element.p1.dy - 35) / element.scale) + element.maxHeight;
          var y2 = -((element.p2.dy - 35) / element.scale) + element.maxHeight;
          var a = (trendLineMax! - y1) * trendLineScale! + trendLineContentRec!;
          var b = (trendLineMax! - y2) * trendLineScale! + trendLineContentRec!;
          var p1 = Offset(element.p1.dx, a);
          var p2 = Offset(element.p2.dx, b);
          canvas.drawLine(
            p1,
            element.p2 == Offset(-1, -1) ? Offset(x, y) : p2,
            Paint()
              ..color = Colors.yellow
              ..strokeWidth = 2,
          );
        });
      }
    }
  }

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineModel point = getItem(index);
    Paint paintY =
        Paint()
          ..color = this.chartColors.vCrossColor
          ..strokeWidth = this.chartStyle.vCrossWidth
          ..isAntiAlias = true;
    double x = getX(index);
    double y = getMainY(point.close);
    // k线图竖线
    canvas.drawLine(
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );

    Paint paintX =
        Paint()
          ..color = this.chartColors.hCrossColor
          ..strokeWidth = this.chartStyle.hCrossWidth
          ..isAntiAlias = true;
    // k线图横线
    canvas.drawLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );
    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0 * scaleX, width: 2.0),
        paintX,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0, width: 2.0 / scaleX),
        paintX,
      );
    }
  }

  TextPainter getTextPainter(text, color) {
    color ??= chartColors.defaultTextColor;
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int? date) => dateFormat(
    DateTime.fromMillisecondsSinceEpoch(
      date ?? DateTime.now().millisecondsSinceEpoch,
    ),
    mFormats,
  );

  double getMainY(double y) => mMainRenderer.getY(y);

  /// 点是否在SecondaryRect中
  bool isInSecondaryRect(Offset point) {
    return mSecondaryRect?.contains(point) ?? false;
  }

  /// 点是否在MainRect中
  bool isInMainRect(Offset point) {
    return mMainRect.contains(point);
  }
}
