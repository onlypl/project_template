import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_template/app/modules/chart/model/k_line_model.dart';

import '../utils/date_format_util.dart';
import '../views/chart_style.dart';
import '../views/k_chart_widget.dart';

///------基础绘制图表画布
abstract class BaseChartPainter extends CustomPainter {
  ///数据源
  List<KLineModel>? datas;

  ///总数据量
  int mItemCount = 0;

  ///数据占屏幕总长度  计算图表总长度mItemCount * mPointWidth;
  double mDataLen = 0.0;

  ///图表样式
  final ChartStyle chartStyle;

  ///点与点之间的间距 数据之间
  late double mPointWidth;

  ///顶部、底部子容器内间距
  double mTopPadding = 30.0, mBottomPadding = 20.0, mChildPadding = 12.0;

  ///图表实际高度和宽度
  late double mDisplayHeight, mWidth;

  ///网格线横线数量和纵线数量
  int mGridRows = 4, mGridColumns = 4;

  ///格式化时间
  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];

  ///主图类型
  MainState mainState;

  ///是否隐藏成交量图
  bool volHidden;

  ///副图类型
  SecondaryState secondaryState;

  ///3块区域大小与位置
  ///主图区域
  late Rect mMainRect;

  ///交易量区域、副图区域
  Rect? mVolRect, mSecondaryRect;

  ///最大可横向滚动范围
  static double maxScrollX = 0.0;

  ///当前显示的起始和结束索引
  int mStartIndex = 0, mStopIndex = 0;

  ///缩放比例、横向滚动的偏移量、用户长按或点击的横向位置
  double scaleX = 1.0, scrollX = 0.0, selectX;

  ///左侧内间距
  double xFrontPadding;

  ///是否是长按状态
  bool isLongPress = false;

  ///是否是点击状态
  bool isOnTap;

  ///是否是点击显示信息弹窗
  bool isTapShowInfoDialog;

  ///是否显示(分时)折线图 falseK线 true分时线
  bool isLine;

  ///实际位移量
  double mTranslateX = double.minPositive;

  ///主图最大值和最小值
  double mMainMaxValue = double.minPositive, mMainMinValue = double.maxFinite;

  ///交易量最大值和最小值
  double mVolMaxValue = double.minPositive, mVolMinValue = double.maxFinite;

  ///副图最大值和最小值
  double mSecondaryMaxValue = double.minPositive,
      mSecondaryMinValue = double.maxFinite;

  ///主图最高点/最低点索引
  int mMainMaxIndex = 0, mMainMinIndex = 0;

  ///主图最高点/最低点
  double mMainHighMaxValue = double.minPositive,
      mMainLowMinValue = double.maxFinite;
  BaseChartPainter(
    this.chartStyle, { //图表样式
    this.datas, //数据数组
    required this.scaleX, //缩放比例
    required this.scrollX, //横向滚动的偏移量
    required this.isLongPress, //是否是长按状态
    required this.selectX, //用户长按或点击的横向位置
    required this.xFrontPadding, //X轴内间距
    this.mainState = MainState.MA, //主图状态:平均线
    this.volHidden = false, //成交量是否隐藏
    this.secondaryState = SecondaryState.MACD, //副图状态:平均线
    this.isOnTap = false, //是否是点击状态
    this.isTapShowInfoDialog = false, //是否是点击显示信息弹窗
    this.isLine = false, //是否显示K线图 trueK线 false分时线
  }) {
    mItemCount = datas?.length ?? 0; //数据量
    mPointWidth = chartStyle.pointWidth; //点与点之间的间距
    mTopPadding = chartStyle.topPadding; //顶部内边距
    mBottomPadding = chartStyle.bottomPadding; //底部内边距
    mChildPadding = chartStyle.childPadding; //子容器内边距
    mGridRows = chartStyle.gridRows; //网格横线数量
    mGridColumns = chartStyle.gridColumns; //网格纵线数量
    mDataLen = mItemCount * chartStyle.pointWidth; //数据占屏幕总长度
    initFormats(); //初始化时间格式
  }

  void initFormats() {
    ///日期格式初始化
    if (chartStyle.dateTimeFormat != null) {
      mFormats = chartStyle.dateTimeFormat!;
      return;
    }

    ///数量小于2的
    if (mItemCount < 2) {
      mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
      return;
    }

    int firstTime = datas?.first.time ?? 0; //第一个数据时间 毫秒值
    int secondTime = datas?[1].time ?? 0; //第二个数据时间 毫秒值
    int time = secondTime - firstTime; //时间差毫秒值
    time ~/= 1000; //毫秒转秒
    //28天及以上
    if (time >= 24 * 60 * 60 * 28) {
      //月线
      mFormats = [yy, '-', mm];
      //1天及以上
    } else if (time >= 24 * 60 * 60) {
      //日线
      mFormats = [yy, '-', mm, '-', dd];
    } else {
      //小时线等
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    mDisplayHeight = size.height - mTopPadding - mBottomPadding; //图表实际高
    mWidth = size.width; //图表宽度
    initRect(size); //初始化三个主图/成交量图/副图区域
    calculateValue(); //绘制的数据范围（起止索引），以及主图、副图、成交量图的最大最小值
    initChartRenderer(); //初始化图表渲染器

    canvas.save(); //保存画布状态 当前画布的状态压入栈中
    canvas.scale(1, 1); //缩放比例
    drawBg(canvas, size); //画背景
    drawGrid(canvas); //画网格

    if (datas != null && datas!.isNotEmpty) {
      drawChart(canvas, size); //画图表
      drawVerticalText(canvas); //画右边值
      drawDate(canvas, size); //画时间

      drawText(canvas, datas!.last, 5); //画值
      drawMaxAndMin(canvas); //画最大最小值
      drawNowPrice(canvas); //画当前价格
      drawCrossLine(canvas, size); //画交叉线
      drawCrossLineText(canvas, size); //画交叉线值

      //如果是长按状态或者点击显示信息弹窗并且点击
      if (isLongPress == true || (isTapShowInfoDialog && isOnTap)) {
        drawCrossLineText(canvas, size); //交叉线值
      }
    }
    canvas.restore(); //save状态 出栈并恢复
  }

  ///初始化图表渲染器
  void initChartRenderer();

  ///画背景
  void drawBg(Canvas canvas, Size size);

  ///画网格
  void drawGrid(canvas);

  ///画图表
  void drawChart(Canvas canvas, Size size);

  ///画右边值
  void drawVerticalText(canvas);

  ///画时间
  void drawDate(Canvas canvas, Size size);

  ///画值
  void drawText(Canvas canvas, KLineModel data, double x);

  ///画最大最小值
  void drawMaxAndMin(Canvas canvas);

  ///画当前价格
  void drawNowPrice(Canvas canvas);

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size);

  ///交叉线值
  void drawCrossLineText(Canvas canvas, Size size);

  /// 初始化区域
  ///将画布高度 mDisplayHeight 拆分为三个区域：
  /// 	1.	主图（K线、MA、BOLL）
  /// 	2.	成交量图（Volume）
  /// 	3.	副图（MACD、KDJ、RSI 等）
  void initRect(Size size) {
    ///如果未隐藏成交量图（volHidden != true），则为其分配 20% 高度。
    double volHeight = volHidden != true ? mDisplayHeight * 0.2 : 0;

    ///如果副图状态不为 NONE，也为其分配 20% 高度。
    double secondaryHeight =
        secondaryState != SecondaryState.NONE ? mDisplayHeight * 0.2 : 0;

    ///主图区域占据剩余所有空间
    double mainHeight = mDisplayHeight;
    mainHeight -= volHeight;
    mainHeight -= secondaryHeight;

    /// 从顶部开始绘制主图，包含顶部内边距 mTopPadding
    mMainRect = Rect.fromLTRB(0, mTopPadding, mWidth, mTopPadding + mainHeight);

    ///紧接主图底部绘制，留出 mChildPadding 间距
    if (volHidden != true) {
      mVolRect = Rect.fromLTRB(
        0,
        mMainRect.bottom + mChildPadding,
        mWidth,
        mMainRect.bottom + volHeight,
      );
    }

    ///位于主图 + 成交量图之下，同样留出 mChildPadding
    if (secondaryState != SecondaryState.NONE) {
      mSecondaryRect = Rect.fromLTRB(
        0,
        mMainRect.bottom + volHeight + mChildPadding,
        mWidth,
        mMainRect.bottom + volHeight + secondaryHeight,
      );
    }
  }

  ///当前图表视图中要绘制的数据范围（起止索引），以及主图、副图、成交量图的最大最小值。
  ///它直接影响图表的坐标缩放和 Y 轴值范围。
  calculateValue() {
    ///没有数据时直接退出，避免空引用异常
    if (datas == null) return;
    if (datas!.isEmpty) return;

    ///计算最大可滚动距离，用于限制图表横向滚动范围（例如拖动到最左边就加载更多历史数据）。
    maxScrollX = getMinTranslateX().abs();

    ///根据滚动偏移 scrollX 设置当前绘图的 mTranslateX（实际位移量）。
    setTranslateXFromScrollX(scrollX);

    ///将屏幕左边界和右边界的坐标转换成实际数据索引，确定当前要显示的 K 线起止范围。
    mStartIndex = indexOfTranslateX(xToTranslateX(0));
    mStopIndex = indexOfTranslateX(xToTranslateX(mWidth));

    ///遍历这段范围内的每一个数据点
    ///在 drawChart()、drawVerticalText() 等方法中按比例绘制图表坐标和形状。
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      var item = datas![i];

      ///	**主图（K 线、MA、BOLL）**的最大值/最小值
      getMainMaxMinValue(item, i);

      ///成交量图的最大值/最小值
      getVolMaxMinValue(item);

      ///**副图指标（如 MACD、RSI、KDJ）**的最大值/最小值
      getSecondaryMaxMinValue(item);
    }
  }

  ///	**主图（K 线、MA、BOLL）**的最大值/最小值
  void getMainMaxMinValue(KLineModel item, int i) {
    double maxPrice, minPrice; //最大/最小价格值
    if (mainState == MainState.MA) {
      //均线 最大值取最高价和各均线中的最大；最小值取最低价和均线中的最小。
      maxPrice = max(item.high, _findMaxMA(item.maValueList ?? [0]));
      minPrice = min(item.low, _findMinMA(item.maValueList ?? [0]));
    } else if (mainState == MainState.BOLL) {
      //布林线 上下轨 up / dn 和蜡烛最高最低价
      maxPrice = max(item.up ?? 0, item.high);
      minPrice = min(item.dn ?? 0, item.low);
    } else {
      //裸K线模式下：仅取每根蜡烛的最高价、最低价。
      maxPrice = item.high;
      minPrice = item.low;
    }

    ///更新主图最大最小值 最高价 最低价
    mMainMaxValue = max(mMainMaxValue, maxPrice);
    mMainMinValue = min(mMainMinValue, minPrice);

    ///当前区间内最高点 / 最低点的位置
    if (mMainHighMaxValue < item.high) {
      mMainHighMaxValue = item.high;
      mMainMaxIndex = i;
    }

    /// 当前区间内最低点 / 最低点的位置
    if (mMainLowMinValue > item.low) {
      mMainLowMinValue = item.low;
      mMainMinIndex = i;
    }
    //如果是折线图模式（非蜡烛），最大最小值取 close 值
    if (isLine == true) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    }
  }

  ///获取均线最大值
  double _findMaxMA(List<double> a) {
    double result = double.minPositive;
    for (double i in a) {
      result = max(result, i);
    }
    return result;
  }

  ///获取均线最小值
  double _findMinMA(List<double> a) {
    double result = double.maxFinite;
    for (double i in a) {
      result = min(result, i == 0 ? double.maxFinite : i);
    }
    return result;
  }

  ///成交量图的最大值/最小值
  void getVolMaxMinValue(KLineModel item) {
    // mVolMaxValue = max(
    //   mVolMaxValue,
    //   max(item.vol, max(item.MA5Volume ?? 0, item.MA10Volume ?? 0)),
    // );
    // mVolMinValue = min(
    //   mVolMinValue,
    //   min(item.vol, min(item.MA5Volume ?? 0, item.MA10Volume ?? 0)),
    // );

    final values = <double>[
      if (item.vol > 0) item.vol,
      if ((item.MA5Volume ?? 0) > 0) item.MA5Volume!,
      if ((item.MA10Volume ?? 0) > 0) item.MA10Volume!,
    ];
    if (values.isNotEmpty) {
      mVolMaxValue = max(mVolMaxValue, values.reduce(max));
      mVolMinValue = min(mVolMinValue, values.reduce(min));
    }
  }

  ///**副图指标（如 MACD、RSI、KDJ）**的最大值/最小值
  void getSecondaryMaxMinValue(KLineModel item) {
    if (secondaryState == SecondaryState.MACD) {
      final values =
          [item.macd, item.dif, item.dea].whereType<double>().toList();
      if (values.isNotEmpty) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, values.reduce(max));
        mSecondaryMinValue = min(mSecondaryMinValue, values.reduce(min));
      }
    } else if (secondaryState == SecondaryState.KDJ) {
      final values = [item.k, item.d, item.j].whereType<double>().toList();
      if (values.isNotEmpty) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, values.reduce(max));
        mSecondaryMinValue = min(mSecondaryMinValue, values.reduce(min));
      }
    } else if (secondaryState == SecondaryState.RSI) {
      if (item.rsi != null) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.rsi!);
        mSecondaryMinValue = min(mSecondaryMinValue, item.rsi!);
      }
    } else if (secondaryState == SecondaryState.WR) {
      mSecondaryMaxValue = 0;
      mSecondaryMinValue = -100;
    } else if (secondaryState == SecondaryState.CCI) {
      if (item.cci != null) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.cci!);
        mSecondaryMinValue = min(mSecondaryMinValue, item.cci!);
      }
    } else {
      mSecondaryMaxValue = 0;
      mSecondaryMinValue = 0;
    }
  }

  ///获取平移的最小值
  double getMinTranslateX() {
    /// 最大可滚动距离 =  -数据占屏幕总长度 + (图表宽度 / 缩放比例) - (点与点之间的间距 / 2) - 左侧内边距
    var x = -mDataLen + (mWidth / scaleX) - (mPointWidth / 2) - xFrontPadding;
    return x >= 0 ? 0.0 : x;
  }

  ///scrollX 转换为 TranslateX
  void setTranslateXFromScrollX(double scrollX) =>
      mTranslateX = scrollX + getMinTranslateX();

  ///将手指点击或绘图中的 x 像素位置，映射到实际图表数据中的逻辑坐标
  /// x             屏幕上的横向像素位置（如点击位置、绘图偏移）
  /// mTranslateX   当前图表平移的总偏移量
  /// scaleX        当前的缩放比例
  double xToTranslateX(double x) => -mTranslateX + x / scaleX;

  ///根据实际位移量获取索引
  int indexOfTranslateX(double translateX) =>
      _indexOfTranslateX(translateX, 0, mItemCount - 1);

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end);
    } else {
      return mid;
    }
  }

  ///根据索引索取x坐标
  ///+ mPointWidth / 2防止第一根和最后一根k线显示不全
  ///@param position 索引值
  ///mPointWidth：每根 K 线在图表上的宽度（包括柱体和间隔）
  ///mPointWidth / 2：让蜡烛图居中显示在其可视区（避免对齐在左边缘）
  double getX(int position) => position * mPointWidth + mPointWidth / 2;

  ///获取索引下标数据
  KLineModel getItem(int position) {
    return datas![position];
    // if (datas != null) {
    //   return datas[position];
    // } else {
    //   return null;
    // }
  }

  ///计算长按后x的值，转换为index
  int calculateSelectedX(double selectX) {
    int mSelectedIndex = indexOfTranslateX(xToTranslateX(selectX));
    if (mSelectedIndex < mStartIndex) {
      mSelectedIndex = mStartIndex;
    }
    if (mSelectedIndex > mStopIndex) {
      mSelectedIndex = mStopIndex;
    }
    return mSelectedIndex;
  }

  ///translateX转化为view中的x
  double translateXtoX(double translateX) =>
      (translateX + mTranslateX) * scaleX;

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
    //    return oldDelegate.datas != datas ||
    //        oldDelegate.datas?.length != datas?.length ||
    //        oldDelegate.scaleX != scaleX ||
    //        oldDelegate.scrollX != scrollX ||
    //        oldDelegate.isLongPress != isLongPress ||
    //        oldDelegate.selectX != selectX ||
    //        oldDelegate.isLine != isLine ||
    //        oldDelegate.mainState != mainState ||
    //        oldDelegate.secondaryState != secondaryState;
  }
}
