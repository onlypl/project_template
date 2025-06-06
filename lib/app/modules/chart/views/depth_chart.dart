import 'dart:math';

import 'package:flutter/material.dart';

import '../model/depth_model.dart';
import 'chart_style.dart';

///深度图-买卖
class DepthChart extends StatefulWidget {
  ///绘制深度图中买入（bids）与卖出（asks）数据
  final List<DepthModel> bids, asks;

  ///格式化价格/数量时保留的小数位数
  final int fixedLength;

  ///买单区域（左侧图）的填充颜色
  final Color? buyPathColor;

  ///卖单区域（右侧图）的填充颜色
  final Color? sellPathColor;

  ///图表的配色
  final ChartColors chartColors;
  DepthChart(
    this.bids, //买入数据
    this.asks, //卖出数据
    this.chartColors, { //图表的配色
    this.fixedLength = 2, //保留的小数位数
    this.buyPathColor, //买单配色
    this.sellPathColor, //卖单配色
  });

  @override
  State<DepthChart> createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  ///长按坐标
  Offset? pressOffset;

  ///是否是长按状态
  bool isLongPress = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///开始长按
      onLongPressStart: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      //长按移动
      onLongPressMoveUpdate: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onTap: () {
        if (isLongPress) {
          isLongPress = false;
          setState(() {});
        }
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: DepthChartPainter(
          widget.bids,
          widget.asks,
          pressOffset,
          isLongPress,
          widget.fixedLength,
          widget.buyPathColor,
          widget.sellPathColor,
          widget.chartColors,
        ),
      ),
    );
  }
}

//深度图渲染器
class DepthChartPainter extends CustomPainter {
  ///买入//卖出
  List<DepthModel>? mBuyData, mSellData;

  ///长按坐标
  Offset? pressOffset;

  ///是否是长按状态
  bool isLongPress;

  ///格式化价格/数量时保留的小数位数
  int? fixedLength;

  ///买单/卖单区域（左侧图）的填充颜色
  Color? mBuyPathColor, mSellPathColor;

  ///图表的配色
  ChartColors chartColors;

  ///底部间距
  double mPaddingBottom = 18.0;

  ///mWidth 绘制画布的宽度（包含买入+卖出区域）
  ///mDrawHeight 实际绘图高度（去除底部 padding）
  ///mDrawWidth 买卖区域的各自宽度（mWidth / 2）

  double mWidth = 0.0, mDrawHeight = 0.0, mDrawWidth = 0.0;

  ///买入/卖出点的宽度
  double? mBuyPointWidth, mSellPointWidth;

  ///mMaxVolume 最大的委托量
  ///mMultiple 每条刻度线之间的量间距(每个点之间的水平间距)
  double? mMaxVolume, mMultiple;

  ///右侧绘制个数
  int mLineCount = 4;

  ///mBuyPath 买盘区域的路径
  ///mSellPath 卖盘区域的路径
  Path? mBuyPath, mSellPath;

  ///买卖出区域边线绘制画笔  //买卖出取悦绘制画笔
  Paint? mBuyLinePaint, //买入单折线
      mSellLinePaint, //卖出单折线
      mBuyPathPaint, //买入单区域填充
      mSellPathPaint, //卖出单区域填充
      selectPaint, //用户长按时高亮选中点的底部和右侧背景填充
      selectBorderPaint; //用户长按时高亮框的边框线，配合 selectPaint 使用

  DepthChartPainter(
    this.mBuyData, //买入数组
    this.mSellData, //卖出数组
    this.pressOffset, //长按坐标
    this.isLongPress, //是否是长按状态
    this.fixedLength, //保留的小数位数
    this.mBuyPathColor, //买单配色
    this.mSellPathColor, //卖单配色
    this.chartColors,
  ) {
    mBuyLinePaint ??=
        Paint()
          ..isAntiAlias = true
          ..color = chartColors.depthBuyColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    mSellLinePaint ??=
        Paint()
          ..isAntiAlias = true
          ..color = chartColors.depthSellColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    mBuyPathPaint ??=
        Paint()
          ..isAntiAlias = true
          ..color =
              (mBuyPathColor ??
                  chartColors.depthBuyColor.withValues(alpha: 0.2))!;
    mSellPathPaint ??=
        Paint()
          ..isAntiAlias = true
          ..color =
              (mSellPathColor ??
                  chartColors.depthSellColor.withValues(alpha: 0.2))!;
    mBuyPath ??= Path();
    mSellPath ??= Path();
    init();
  }

  void init() {
    //判断买入/卖出数据是否为空或未初始化。
    if (mBuyData == null ||
        mBuyData!.isEmpty ||
        mSellData == null ||
        mSellData!.isEmpty) {
      return;
    }
    // 	•	初始化最大成交量为买入数据的第一个值。
    // 	•	与卖出数据的最后一个值比较，取更大值。
    // 	•	将结果乘以 1.05，多加 5% 留白空间，避免柱状图贴顶。
    mMaxVolume = mBuyData![0].vol;
    mMaxVolume = max(mMaxVolume!, mSellData!.last.vol);
    mMaxVolume = mMaxVolume! * 1.05;

    //用最大值除以 mLineCount（通常是 4），表示图表纵向每条刻度线之间的数值跨度
    mMultiple = mMaxVolume! / mLineCount;
    fixedLength ??= 2;

    //初始化选中样式画笔
    selectPaint =
        Paint()
          ..isAntiAlias = true
          ..color = chartColors.selectFillColor;
    selectBorderPaint =
        Paint()
          ..isAntiAlias = true
          ..color = chartColors.selectBorderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //判断买入/卖出数据是否为空或未初始化。
    if (mBuyData == null ||
        mSellData == null ||
        mBuyData!.isEmpty ||
        mSellData!.isEmpty) {
      return;
    }
    //初始化画布宽以及实际绘制区域宽高
    mWidth = size.width;
    mDrawWidth = mWidth / 2;
    mDrawHeight = size.height - mPaddingBottom;
    canvas.save();
    //绘制买入区域
    drawBuy(canvas);
    //绘制卖出区域
    drawSell(canvas);

    //绘制界面相关文案
    drawText(canvas);
    canvas.restore();
  }

  ///绘制买方（Buy）委托区域的线条和填充图形
  void drawBuy(Canvas canvas) {
    //计算每个点的横坐标间距 确定买盘区域每个点的水平间距
    mBuyPointWidth =
        (mDrawWidth / (mBuyData!.length - 1 == 0 ? 1 : mBuyData!.length - 1));
    //重置路径并开始遍历绘制
    mBuyPath!.reset();
    double x;
    double y;
    for (int i = 0; i < mBuyData!.length; i++) {
      // 第一个点初始化路径起点
      if (i == 0) {
        mBuyPath!.moveTo(0, getY(mBuyData![0].vol));
      }
      //确定当前点坐标
      x = mBuyPointWidth! * i;
      y = getY(mBuyData![i].vol);

      //从第二个点开始绘制线段 将点与上一个点连接，画出折线
      if (i >= 1) {
        canvas.drawLine(
          Offset(mBuyPointWidth! * (i - 1), getY(mBuyData![i - 1].vol)),
          Offset(x, y),
          mBuyLinePaint!,
        );
      }

      //如果不是最后一个点，用二阶贝塞尔曲线连接下一个点
      if (i != mBuyData!.length - 1) {
        //填充区域曲线更平滑
        mBuyPath!.quadraticBezierTo(
          x,
          y,
          mBuyPointWidth! * (i + 1),
          getY(mBuyData![i + 1].vol),
        );
      } else {
        //最后一个点：补全封闭路径形成填充区域

        //若只一个点，直接拉伸到底部并封闭
        if (i == 0) {
          mBuyPath!.lineTo(mDrawWidth, y);
          mBuyPath!.lineTo(mDrawWidth, mDrawHeight);
          mBuyPath!.lineTo(0, mDrawHeight);
        } else {
          //否则，从最后一点向下连到底部，再向左连回起点
          mBuyPath!.quadraticBezierTo(x, y, x, mDrawHeight);
          mBuyPath!.quadraticBezierTo(x, mDrawHeight, 0, mDrawHeight);
        }
        mBuyPath!.close();
      }
    }
    canvas.drawPath(mBuyPath!, mBuyPathPaint!);
  }

  ///绘制卖方（Buy）委托区域的线条和填充图形
  void drawSell(Canvas canvas) {
    //计算每个点的横坐标间距 确定买盘区域每个点的水平间距
    mSellPointWidth =
        (mDrawWidth / (mSellData!.length - 1 == 0 ? 1 : mSellData!.length - 1));
    //重置路径并开始遍历绘制
    mSellPath!.reset();

    double x;
    double y;
    for (int i = 0; i < mSellData!.length; i++) {
      // 第一个点初始化路径起点
      if (i == 0) {
        mSellPath!.moveTo(mDrawWidth, getY(mSellData![0].vol));
      }

      //确定当前点坐标
      x = (mSellPointWidth! * i) + mDrawWidth;
      y = getY(mSellData![i].vol);

      //从第二个点开始绘制线段 将点与上一个点连接，画出折线
      if (i >= 1) {
        canvas.drawLine(
          Offset(
            (mSellPointWidth! * (i - 1)) + mDrawWidth,
            getY(mSellData![i - 1].vol),
          ),
          Offset(x, y),
          mSellLinePaint!,
        );
      }

      //如果不是最后一个点，用二阶贝塞尔曲线连接下一个点
      if (i != mSellData!.length - 1) {
        //填充区域曲线更平滑
        mSellPath!.quadraticBezierTo(
          x,
          y,
          (mSellPointWidth! * (i + 1)) + mDrawWidth,
          getY(mSellData![i + 1].vol),
        );
      } else {
        //最后一个点：补全封闭路径形成填充区域

        //若只一个点，直接拉伸到底部并封闭
        if (i == 0) {
          mSellPath!.lineTo(mWidth, y);
          mSellPath!.lineTo(mWidth, mDrawHeight);
          mSellPath!.lineTo(mDrawWidth, mDrawHeight);
        } else {
          //否则，从最后一点向下连到底部，再向左连回起点
          mSellPath!.quadraticBezierTo(mWidth, y, x, mDrawHeight);
          mSellPath!.quadraticBezierTo(x, mDrawHeight, mDrawWidth, mDrawHeight);
        }
        mSellPath!.close();
      }
    }
    canvas.drawPath(mSellPath!, mSellPathPaint!);
  }

  ///绘制相关文案
  void drawText(Canvas canvas) {
    //右侧 纵轴上绘制量化参考刻度值（委托量）
    double value;
    String str;
    //循环绘制 mLineCount 条纵向坐标参考刻度（比如常用的4条：最大值、中上、中下、最小值）
    for (int j = 0; j < mLineCount; j++) {
      //计算每条刻度线对应的“成交量”数值
      //mMaxVolume 是买卖盘中最大的成交量
      //mMultiple 是每条线之间的成交量间距
      //第 0 条是最大值，后面依次减小
      value = mMaxVolume! - mMultiple! * j;
      //格式化显示文本，保留指定位数小数
      str = value.toStringAsFixed(fixedLength!);
      //创建 TextPainter 来布局文本
      //把文本绘制到画布上，右对齐
      //纵向位置按等分间隔绘制（靠近每条刻度线的水平位置）
      var tp = getTextPainter(str);
      tp.layout();
      tp.paint(
        canvas,
        Offset(mWidth - tp.width, mDrawHeight / mLineCount * j + tp.height / 2),
      );
    }

    //    startText | ← leftHalfText → | ← centerPrice → | ← rightHalfText → | endText（卖）      |
    // |-------------|------------------|------------------|--------------------|---------------|
    // |  起始价（买） |      左半区域中点  |    整体中间价格    |      右半区域中点    |   卖盘末价     |
    //底部绘制买入区域的起始价格文本
    //获取买单列表中的第一个价格（即价格最低的买入挂单）
    // •	x=0：靠左侧；
    // •	y 通过 getBottomTextY 方法计算，使其对齐到底部区域。
    var startText = mBuyData!.first.price.toStringAsFixed(fixedLength!);
    TextPainter startTP = getTextPainter(startText);
    startTP.layout();
    startTP.paint(canvas, Offset(0, getBottomTextY(startTP.height)));

    //计算中间价格
    double centerPrice = (mBuyData!.last.price + mSellData!.first.price) / 2;
    var center = centerPrice.toStringAsFixed(fixedLength!);
    TextPainter centerTP = getTextPainter(center);
    centerTP.layout();
    centerTP.paint(
      canvas,
      Offset(mDrawWidth - centerTP.width / 2, getBottomTextY(centerTP.height)),
    );

    //绘制最右侧卖出价格
    //获取卖单列表的最后一个价格（即最右侧卖出价格）
    var endText = mSellData!.last.price.toStringAsFixed(fixedLength!);
    TextPainter endTP = getTextPainter(endText);
    endTP.layout();
    endTP.paint(
      canvas,
      Offset(mWidth - endTP.width, getBottomTextY(endTP.height)),
    );

    //左半中间价格（买盘中间偏右）
    var leftHalfText = ((mBuyData!.first.price + centerPrice) / 2)
        .toStringAsFixed(fixedLength!);
    TextPainter leftHalfTP = getTextPainter(leftHalfText);
    leftHalfTP.layout();
    leftHalfTP.paint(
      canvas,
      Offset(
        (mDrawWidth - leftHalfTP.width) / 2,
        getBottomTextY(leftHalfTP.height),
      ),
    );

    //右半中间价格（卖盘中间偏左）
    var rightHalfText = ((mSellData!.last.price + centerPrice) / 2)
        .toStringAsFixed(fixedLength!);
    TextPainter rightHalfTP = getTextPainter(rightHalfText);
    rightHalfTP.layout();
    rightHalfTP.paint(
      canvas,
      Offset(
        (mDrawWidth + mWidth - rightHalfTP.width) / 2,
        getBottomTextY(rightHalfTP.height),
      ),
    );
  }

  ///绘制选中点圆圈
  void drawSelectView(Canvas canvas, int index, bool isLeft) {
    ///根据左右判断获取买/卖数据
    DepthModel entity = isLeft ? mBuyData![index] : mSellData![index];

    ///根据左右判断获取买/卖x坐标
    double dx = isLeft ? getBuyX(index) : getSellX(index);

    double radius = 8.0;
    if (dx < mDrawWidth) {
      ///买入
      // 实心小圆
      canvas.drawCircle(
        Offset(dx, getY(entity.vol)),
        radius / 3,
        mBuyLinePaint!..style = PaintingStyle.fill,
      );

      // 空心大圆
      canvas.drawCircle(
        Offset(dx, getY(entity.vol)),
        radius,
        mBuyLinePaint!..style = PaintingStyle.stroke,
      );
    } else {
      ///卖出
      // 实心小圆
      canvas.drawCircle(
        Offset(dx, getY(entity.vol)),
        radius / 3,
        mSellLinePaint!..style = PaintingStyle.fill,
      );
      // 空心大圆
      canvas.drawCircle(
        Offset(dx, getY(entity.vol)),
        radius,
        mSellLinePaint!..style = PaintingStyle.stroke,
      );
    }

    //画底部
    TextPainter priceTP = getTextPainter(
      entity.price.toStringAsFixed(fixedLength!),
    );
    priceTP.layout();
    double left;
    if (dx <= priceTP.width / 2) {
      left = 0;
    } else if (dx >= mWidth - priceTP.width / 2) {
      left = mWidth - priceTP.width;
    } else {
      left = dx - priceTP.width / 2;
    }
    Rect bottomRect = Rect.fromLTRB(
      left - 3,
      mDrawHeight + 3,
      left + priceTP.width + 3,
      mDrawHeight + mPaddingBottom,
    );
    canvas.drawRect(bottomRect, selectPaint!);
    canvas.drawRect(bottomRect, selectBorderPaint!);
    priceTP.paint(
      canvas,
      Offset(
        bottomRect.left + (bottomRect.width - priceTP.width) / 2,
        bottomRect.top + (bottomRect.height - priceTP.height) / 2,
      ),
    );
    //画左边
    TextPainter amountTP = getTextPainter(
      entity.vol.toStringAsFixed(fixedLength!),
    );
    amountTP.layout();
    double y = getY(entity.vol);
    double rightRectTop;
    if (y <= amountTP.height / 2) {
      rightRectTop = 0;
    } else if (y >= mDrawHeight - amountTP.height / 2) {
      rightRectTop = mDrawHeight - amountTP.height;
    } else {
      rightRectTop = y - amountTP.height / 2;
    }
    Rect rightRect = Rect.fromLTRB(
      mWidth - amountTP.width - 6,
      rightRectTop - 3,
      mWidth,
      rightRectTop + amountTP.height + 3,
    );
    canvas.drawRect(rightRect, selectPaint!);
    canvas.drawRect(rightRect, selectBorderPaint!);
    amountTP.paint(
      canvas,
      Offset(
        rightRect.left + (rightRect.width - amountTP.width) / 2,
        rightRect.top + (rightRect.height - amountTP.height) / 2,
      ),
    );
  }

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end, Function getX) {
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
      return _indexOfTranslateX(translateX, start, mid, getX);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end, getX);
    } else {
      return mid;
    }
  }

  ///换为屏幕坐标系的 Y 值
  double getY(double volume) =>
      mDrawHeight - (mDrawHeight) * volume / mMaxVolume!;

  ///根据买入当前位置获取当前的买入横坐标
  double getBuyX(int position) => position * mBuyPointWidth!;

  ///根据卖出当前位置获取当前的卖出横坐标
  double getSellX(int position) => position * mSellPointWidth! + mDrawWidth;

  ///根据文本高度获取当前的文本纵坐标
  double getBottomTextY(double textHeight) =>
      (mPaddingBottom - textHeight) / 2 + mDrawHeight;

  ///获取文本绘制器
  getTextPainter(String text, [Color color = Colors.white]) => TextPainter(
    text: TextSpan(text: "$text", style: TextStyle(color: color, fontSize: 10)),
    textDirection: TextDirection.ltr,
  );

  @override
  bool shouldRepaint(DepthChartPainter oldDelegate) {
    //    return oldDelegate.mBuyData != mBuyData ||
    //        oldDelegate.mSellData != mSellData ||
    //        oldDelegate.isLongPress != isLongPress ||
    //        oldDelegate.pressOffset != pressOffset;
    return true;
  }
}
