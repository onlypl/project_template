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
          ///*****手指抬起
          onTapUp: (details) {
            ///如果当前不是趋势线模式（!isTrendLine）且点击在副图区域，
            ///就调用 onSecondaryTap。
            if (!widget.isTrendLine &&
                widget.onSecondaryTap != null &&
                _painter.isInSecondaryRect(details.localPosition)) {
              widget.onSecondaryTap!();
            }

            ///当用户点击主图区域且当前不是趋势线模式（isTrendLine == false）时，
            ///根据点击位置更新选中点，并触发刷新
            if (!widget.isTrendLine &&
                _painter.isInMainRect(details.localPosition)) {
              ///当前是点击状态，将用于控制 UI 绘制逻辑，比如是否展示 InfoWindow
              isOnTap = true;

              ///判断是否需要更新选中位置
              ///如果点击位置 localPosition.dx 与当前选中点 mSelectX 不同，
              ///并且开启了点击显示详情的开关 isTapShowInfoDialog，
              ///则更新 mSelectX 并触发 UI 重绘。
              if (mSelectX != details.localPosition.dx &&
                  widget.isTapShowInfoDialog) {
                mSelectX = details.localPosition.dx;
                notifyChanged();
              }
            }

            ///在趋势线绘制模式 (isTrendLine == true) 下，处理单击事件以绘制趋势线的起点和终点坐标
            ///当前处于趋势线绘制模式
            ///当前不是长按状态（避免和拖动趋势线的逻辑冲突）
            ///enableCordRecord 为 true，表示允许记录一个坐标点（这个标志在长按结束时被设置为 true）
            if (widget.isTrendLine && !isLongPress && enableCordRecord) {
              ///重置记录标志
              enableCordRecord = false;

              ///记录点击位置为新点 p1
              Offset p1 = Offset(getTrendLineX(), mSelectY);

              ///添加新趋势线
              ///第一次点击：记录起点
              if (!waitingForOtherPairofCords) {
                lines.add(
                  TrendLine(p1, Offset(-1, -1), trendLineMax!, trendLineScale!),
                );
              }

              ///第二次点击：补上终点
              ///	•	第一次点击 → 设置 waitingForOtherPairofCords = true
              /// •	第二次点击 → 组合成完整 TrendLine，设置 waitingForOtherPairofCords = false
              if (waitingForOtherPairofCords) {
                ///此时把之前只记录起点的线移除，并补上当前点作为终点
                var a = lines.last;
                lines.removeLast();
                lines.add(TrendLine(a.p1, p1, trendLineMax!, trendLineScale!));
                waitingForOtherPairofCords = false;
              } else {
                ///控制下次是否等待下一个坐标
                waitingForOtherPairofCords = true;
              }

              ///通知重绘-界面刷新
              notifyChanged();
            }
          },

          ///*****水平滑动-开始
          onHorizontalDragDown: (details) {
            ///拖动开始时取消“单击”标志，防止拖动操作被误认为点击（tap）。
            isOnTap = false;

            ///如果当前有惯性滑动动画（fling），立即停止动画，以便接管控制权进行手动拖动。
            _stopAnimation();

            ///通知系统“正在拖动中”，可能用于外部监听（widget.isOnDrag），或者内部逻辑调整 UI 状态
            _onDragChanged(true);
          },

          ///*****水平滑动-进行中
          onHorizontalDragUpdate: (details) {
            ///防止冲突：如果当前是缩放（双指捏合）或长按状态，直接返回，不进行横向滚动
            if (isScale || isLongPress) return;

            /// 	•details.primaryDelta 是本次横向滑动的像素偏移值。
            /// 	•	primaryDelta / mScaleX 将滑动距离转换为缩放后的偏移。
            /// 	•	+ mScrollX 表示在当前滚动位置基础上加上偏移值。
            /// 	•	.clamp(...) 保证滚动位置不会超出图表的可滚动范围（防止溢出左/右边界）
            mScrollX =
                ((details.primaryDelta ?? 0) / mScaleX + mScrollX)
                    .clamp(0.0, ChartPainter.maxScrollX)
                    .toDouble();

            ///通知重绘-界面刷新
            notifyChanged();
          },

          ///*****水平滑动-结束
          onHorizontalDragEnd: (details) {
            ///details.velocity.pixelsPerSecond.dx：表示水平方向上的滑动速度（像素/秒），为正表示向右滑动，为负表示向左滑动。
            var velocity = details.velocity.pixelsPerSecond.dx;

            ///创建一个惯性滑动动画，让图表在用户抬手后继续“滑动一段距离并减速”
            _onFling(velocity);
          },

          ///*****水平滑动-取消 重置“正在拖动”的状态
          onHorizontalDragCancel: () => _onDragChanged(false),

          ///*****双指缩放手势-开始
          onScaleStart: (_) {
            ///标记当前用户正在进行缩放
            isScale = true;
          },

          ///*****双指缩放手势-进行中
          onScaleUpdate: (details) {
            ///如果当前处于拖拽中（isDrag 为 true）或长按中（isLongPress 为 true），则不处理缩放
            if (isDrag || isLongPress) return;
            // •	details.scale 是 Flutter 提供的当前缩放因子（从手势事件中获取）。
            // •	_lastScale 是缩放开始前的缩放倍数，乘以 details.scale 得到新的缩放比例。
            // •	.clamp(0.5, 2.2) 限制了缩放范围，防止放得太大或缩得太小：
            // •	最小缩放 0.5（即缩小一半）
            // •	最大缩放 2.2（即放大 2.2 倍）
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);

            ///通知重绘-界面刷新
            notifyChanged();
          },

          ///*****双指缩放手势-结束
          onScaleEnd: (details) {
            ///表示当前缩放手势已结束
            isScale = false;

            ///当前缩放比例 mScaleX 存储到 _lastScale 中
            ///为了在下次 onScaleUpdate 里继续基于当前缩放比例进行乘积计算
            _lastScale = mScaleX;
          },

          ///*****长按-开始
          onLongPressStart: (details) {
            ///表示进入“长按模式”，关闭单击逻辑。
            isOnTap = false;
            isLongPress = true;

            ///如果当前处于拖拽中（isDrag 为 true）或长按中（isLongPress 为 true），则不处理长按
            if (isDrag || isLongPress) return;

            ///普通模式下：更新选中位置并刷新视图
            if ((mSelectX != details.localPosition.dx ||
                    mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              notifyChanged();
            }

            ///趋势线模式下：初始化第一个点
            ///第一次长按时，记录起点坐标；这是第一段趋势线的开始
            if (widget.isTrendLine && changeinXposition == null) {
              mSelectX = changeinXposition = details.localPosition.dx;
              mSelectY = changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }

            ///趋势线模式下：更新当前拖动点
            ///第二次或后续长按时，更新坐标点，配合拖动操作使趋势线跟随移动
            if (widget.isTrendLine && changeinXposition != null) {
              changeinXposition = details.localPosition.dx;
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },

          ///*****长按-移动中
          onLongPressMoveUpdate: (details) {
            ///非趋势线模式（用于显示十字线）
            if ((mSelectX != details.localPosition.dx ||
                    mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              mSelectY = details.localPosition.dy;
              notifyChanged();
            }

            ///、趋势线模式（用于拖动未完成趋势线的点）
            ///	•	根据当前移动距离来动态偏移 mSelectX/Y
            /// 	•	changeinXposition/Yposition 用来记录上一次触点位置
            /// 	•	这样可以形成类似“吸附/拖动点”的体验，趋势线跟随手指移动
            if (widget.isTrendLine) {
              mSelectX =
                  mSelectX + (details.localPosition.dx - changeinXposition!);
              changeinXposition = details.localPosition.dx;
              mSelectY =
                  mSelectY + (details.globalPosition.dy - changeinYposition!);
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },

          ///*****长按-结束
          onLongPressEnd: (details) {
            ///表示长按已结束，相关 UI（如十字线、趋势线）可以停止显示
            isLongPress = false;

            ///表示允许记录趋势线坐标，下一次点击即可作为新的点加入。
            enableCordRecord = true;

            ///清除当前显示的 info window（例如数据浮窗）
            mInfoWindowStream?.sink.add(null);
            notifyChanged();
          },

          ///
          child: Stack(
            children: [
              //自定义绘图
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: _painter,
              ),
              if (widget.showInfoDialog) _buildInfoDialog(),
            ],
          ),
        );
      },
    );
  }

  ///停止当前的惯性滑动动画，并根据参数是否更新 UI 状态
  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  ///更新图表的“拖动状态”，并通知外部监听器
  void _onDragChanged(bool isOnDrag) {
    ///表示当前是否处于“拖动”过程中
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      ///通知外部监听器
      widget.isOnDrag!(isDrag);
    }
  }

  ///追踪动画开始、过程中 scrollX 的变化以及动画结束状态
  ///	•	动画是否触发；
  ///	•	动画过程中 mScrollX 的变化；
  /// •	是否触发了 onLoadMore 回调；
  /// •	动画是否被中途停止或正常完成。
  void _onFling(double x) {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );
    aniX = null;
    aniX = Tween<double>(
      begin: mScrollX,
      end: x * widget.flingRatio + mScrollX,
    ).animate(
      CurvedAnimation(parent: _controller!.view, curve: widget.flingCurve),
    );
    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller!.forward();
  }

  ///刷新页面
  void notifyChanged() => setState(() {});

  late List<String> infos;

  ///在 K 线图上长按或点击后，显示一块悬浮的信息弹窗，展示当前 K 线的详细数据
  ///包括时间、开盘价、最高价、最低价、收盘价、涨跌额、涨跌幅、成交量等
  ///	•	监听 Stream 的数据流
  /// •	获取对应 K 线数据
  /// •	构建信息浮窗以显示 K 线详情
  /// •	支持中英文动态翻译
  /// •	支持多种显示样式（Material or 非 Material）
  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowModel?>(
      stream: mInfoWindowStream?.stream,
      builder: (context, snapshot) {
        ///返回空容器
        ///	•	非长按或非点击
        /// •	或当前是折线图（不展示 InfoDialog）
        /// •	或数据为空
        if ((!isLongPress && !isOnTap) ||
            widget.isLine == true ||
            !snapshot.hasData ||
            snapshot.data?.kLineModel == null) {
          return Container();
        }

        /// 数据处理逻辑
        /// •	change 是涨跌额，若无则用 close - open 计算。
        /// •	ratio 是涨跌幅百分比，若无则计算 (涨跌 / open) * 100
        KLineModel entity = snapshot.data!.kLineModel;
        double upDown = entity.change ?? entity.close - entity.open;
        double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;

        final double? entityAmount = entity.amount;

        ///infos 列表内容
        ///这是传入给 ListView.builder 的数据源，包括格式化后的时间、价格、涨跌幅、成交量（如果有）等信息。
        infos = [
          getDate(entity.time),
          entity.open.toStringAsFixed(widget.fixedLength),
          entity.high.toStringAsFixed(widget.fixedLength),
          entity.low.toStringAsFixed(widget.fixedLength),
          entity.close.toStringAsFixed(widget.fixedLength),
          "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
          "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
          if (entityAmount != null) entityAmount.toInt().toString(),
        ];

        ///UI 构建逻辑
        ///左右位置取决于当前点击是否在左边（防止遮挡）
        final dialogPadding = 4.0;

        ///弹窗宽度为 mWidth / 3
        final dialogWidth = mWidth / 3;
        return Container(
          margin: EdgeInsets.only(
            left:
                snapshot.data!.isLeft
                    ? dialogPadding
                    : mWidth - dialogWidth - dialogPadding,
            top: 25,
          ),
          width: dialogWidth,
          decoration: BoxDecoration(
            color: widget.chartColors.selectFillColor,
            border: Border.all(
              color: widget.chartColors.selectBorderColor,
              width: 0.5,
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(dialogPadding),
            itemCount: infos.length,
            itemExtent: 14.0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final translations =
                  widget.isChinese
                      ? kChartTranslations['zh_CN']!
                      : widget.translations.of(context);

              return _buildItem(infos[index], translations.byIndex(index));
            },
          ),
        );
      },
    );
  }

  ///弹窗item
  Widget _buildItem(String info, String infoName) {
    Color color = widget.chartColors.infoWindowNormalColor;
    if (info.startsWith("+")) {
      color = widget.chartColors.infoWindowUpColor;
    } else if (info.startsWith("-")) {
      color = widget.chartColors.infoWindowDnColor;
    }

    final infoWidget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            "$infoName",
            style: TextStyle(
              color: widget.chartColors.infoWindowTitleColor,
              fontSize: 10.0,
            ),
          ),
        ),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
    return widget.materialInfoDialog
        ? Material(color: Colors.transparent, child: infoWidget)
        : infoWidget;
  }

  ///日期格式化
  String getDate(int? date) => dateFormat(
    DateTime.fromMillisecondsSinceEpoch(
      date ?? DateTime.now().millisecondsSinceEpoch,
    ),
    widget.timeFormat,
  );
}
