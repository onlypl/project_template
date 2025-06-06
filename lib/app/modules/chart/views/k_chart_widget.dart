import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_template/app/modules/chart/model/k_line_model.dart';

import '../model/info_window_model.dart';
import '../renderer/chart_painter.dart';
import '../renderer/main_renderer.dart';
import '../utils/chart_translations.dart';
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
  ///数据
  final List<KLineModel>? datas;

  ///主图类型
  final MainState mainState;

  ///成交量是否隐藏
  final bool volHidden;

  ///副图类型
  final SecondaryState secondaryState;

  ///副图点击回调
  final Function()? onSecondaryTap;

  ///是否是折线图
  final bool isLine;

  ///是否开启单击显示详情数据
  final bool isTapShowInfoDialog;

  ///是否隐藏网格
  final bool hideGrid;

  @Deprecated('Use `translations` instead.')
  final bool isChinese;

  ///是否显示最高价格
  final bool showNowPrice;

  ///是否显示信息弹窗
  final bool showInfoDialog;

  ///Material风格的信息弹窗
  final bool materialInfoDialog;

  ///图表国际化配置
  final Map<String, ChartTranslations> translations;

  ///时间格式化数组
  final List<String> timeFormat;

  ///当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;

  ///价格固定小数位
  final int fixedLength;

  ///均线周期列表（MA）
  final List<int> maDayList;

  ///惯性滑动动画的持续时间（单位：毫秒）
  final int flingTime;

  ///惯性滑动的速度衰减比例。值越大，滑动距离越长
  final double flingRatio;

  ///动画使用的曲线函数
  final Curve flingCurve;

  ///true: 表示当前图表正在被拖动（手指滑动中）
  ///false: 表示拖动结束或取消
  final Function(bool)? isOnDrag;

  ///颜色配置
  final ChartColors chartColors;

  ///间距宽高等样式配置
  final ChartStyle chartStyle;

  ///主图价格显示方向
  final VerticalTextAlignment verticalTextAlignment;

  ///是否启用趋势线绘制
  final bool isTrendLine;

  ///X轴内间距
  final double xFrontPadding;

  const KChartWidget(
    this.datas,
    this.chartColors,
    this.chartStyle, {
    super.key,
    required this.isTrendLine,
    this.xFrontPadding = 100,
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.onSecondaryTap,
    this.volHidden = false,
    this.isLine = false,
    this.isTapShowInfoDialog = false,
    this.hideGrid = false,
    @Deprecated('Use `translations` instead.') this.isChinese = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.materialInfoDialog = true,
    this.translations = kChartTranslations,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.verticalTextAlignment = VerticalTextAlignment.left,
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

  ///控制 K 线图上 Info 弹窗的数据流
  StreamController<InfoWindowModel?>? mInfoWindowStream;

  ///图表总宽和总高
  double mHeight = 0, mWidth = 0;

  ///动画控制器
  AnimationController? _controller;

  ///控制图表横向滑动时的动画值
  Animation<double>? aniX;

  ///趋势线数组
  List<TrendLine> lines = [];

  ///趋势线绘制模式”中临时记录用户长按或拖动时的 X 坐标位置变
  double? changeinXposition;

  ///趋势线绘制模式”中临时记录用户长按或拖动时的 Y 坐标位置变
  double? changeinYposition;

  ///用于记录当前选中的 Y 坐标，配合 mSelectX 共同确定图表上趋势线的点位
  double mSelectY = 0.0;

  ///表示当前是否已经绘制了 第一点，正在等待第二个点来完成一条趋势线
  bool waitingForOtherPairofCords = false;

  ///趋势线：表示是否允许记录一对坐标点（即是否已完成长按并松手操作）。
  bool enableCordRecord = false;

  ///横轴缩放比例
  double getMinScrollX() {
    return mScaleX;
  }

  ///记录上一次手势缩放操作时的缩放比例
  double _lastScale = 1.0;

  /// isScale 用户是否正在进行双指缩放（onScaleStart -> onScaleUpdate）
  /// isDrag 用户是否正在拖动图表（onHorizontalDragStart -> onHorizontalDragUpdate）
  /// isLongPress 用户是否处于长按状态（onLongPressStart -> onLongPressEnd）
  /// isOnTap 用户是否刚点击（单击）了图表（在 onTapUp 中设为 true）
  bool isScale = false, isDrag = false, isLongPress = false, isOnTap = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowModel?>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //数组没有数据 初始化参数：选中位置 滑动偏移 缩放比例
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }

    ///图表画
    final _painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      lines: lines, //For TrendLine
      xFrontPadding: widget.xFrontPadding,
      isTrendLine: widget.isTrendLine, //For TrendLine
      selectY: mSelectY, //For TrendLine
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPress: isLongPress,
      isOnTap: isOnTap,
      isTapShowInfoDialog: widget.isTapShowInfoDialog,
      mainState: widget.mainState,
      volHidden: widget.volHidden,
      secondaryState: widget.secondaryState,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      sink: mInfoWindowStream?.sink,
      fixedLength: widget.fixedLength,
      maDayList: widget.maDayList,
      verticalTextAlignment: widget.verticalTextAlignment,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        //获取父容器的最大宽高
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;
        return GestureDetector(
          ///手指抬起
          onTapUp: (details) {
            ///如果当前不是趋势线模式（!isTrendLine）且点击在副图区域，
            ///就调用 onSecondaryTap。
            if (!widget.isTrendLine &&
                widget.onSecondaryTap != null &&
                _painter.isInSecondaryRect(details.localPosition)) {
              widget.onSecondaryTap!();
            }
          },

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
                // painter: _painter,
              ),
              // if (widget.showInfoDialog) _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }
}
