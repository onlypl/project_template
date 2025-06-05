import 'dart:async';
import 'dart:ui';

import 'package:project_template/app/modules/chart/model/k_line_model.dart';
import 'package:project_template/app/modules/chart/renderer/base_chart_painter.dart';

import '../model/info_window_model.dart';
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
    required xFrontPadding, //左侧内间距
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
    if (datas != null && datas!.isNotEmpty) {
      var t = datas![0];
      fixedLength = NumberUtil.getMaxDecimalLength(
        t.open,
        t.close,
        t.high,
        t.low,
      );
    }

    ///主图渲染
    mMainRenderer = MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      mTopPadding,
      mainState,
      isLine,
      fixedLength,
      this.chartStyle,
      this.chartColors,
      this.scaleX,
      verticalTextAlignment,
      maDayList,
    );
  }

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
}
