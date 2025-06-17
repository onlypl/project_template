import 'dart:async';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class _Rule {
  final int start;
  final int duration;
  final double rate;

  const _Rule({
    required this.start,
    required this.duration,
    required this.rate,
  });
}

class JackpotWidget extends StatefulWidget {
  const JackpotWidget({super.key});

  @override
  State<JackpotWidget> createState() => _JackpotWidgetState();
}

class _JackpotWidgetState extends State<JackpotWidget> {
  late Timer _timer;
  double _currentAmount = 0;

  final double baseAmount = 1000000;
  final int baseTime = 1749691340; // UTC秒（与JS一致）
  final List<_Rule> rules = [
    _Rule(start: 0, duration: 5, rate: 20.9),
    _Rule(start: 5, duration: 2, rate: 10.1),
    _Rule(start: 7, duration: 3, rate: 5.3),
    _Rule(start: 10, duration: 4, rate: 38.3),
    _Rule(start: 14, duration: 3, rate: 18.2),
    _Rule(start: 17, duration: 4, rate: 12.4),
    _Rule(start: 21, duration: 4, rate: 13.5),
    _Rule(start: 25, duration: 5, rate: 9.4),
    _Rule(start: 30, duration: 2, rate: 49.2),
    _Rule(start: 32, duration: 3, rate: 12.5),
    _Rule(start: 35, duration: 2, rate: 3.5),
    _Rule(start: 37, duration: 3, rate: 8.3),
    _Rule(start: 40, duration: 5, rate: 7.2),
    _Rule(start: 45, duration: 2, rate: 6.1),
    _Rule(start: 47, duration: 3, rate: 36.4),
    _Rule(start: 50, duration: 4, rate: 12.2),
    _Rule(start: 54, duration: 3, rate: 5.4),
    _Rule(start: 57, duration: 3, rate: 4.8),
  ];
  int style = 3;
  String imgPath = 'assets/images/jackpot_bg3.png';

  ///金额滚动的顶部间距
  double numberMarginTop = 38.w;
  Axis scrollAxis = Axis.vertical;

  ///文字
  double textBgMaxWidth = 257.w;
  double textBgHeight = 16.w;
  double textBgMarginBottom = 6.w;
  @override
  void initState() {
    super.initState();
    style = 3;

    ///样式1
    if (style == 1) {
      imgPath = 'assets/images/jackpot_bg1.png';
      numberMarginTop = 36.w;
      scrollAxis = Axis.vertical;
      textBgMarginBottom = 0;
      textBgHeight = 32.w;
      textBgMaxWidth = 161.w;

      ///样式2
    } else if (style == 2) {
      imgPath = 'assets/images/jackpot_bg1.png';
      numberMarginTop = 40.w;
    }
    ///样式3
    else if (style == 3) {
      imgPath = 'assets/images/jackpot_bg2.png';
      textBgMaxWidth = 335.w;
      textBgMarginBottom = 7.w;
    }
    _updateAmount();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _updateAmount());
  }

  void _updateAmount() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final totalElapsed = now - baseTime;

    double amount = baseAmount;

    if (totalElapsed > 0) {
      final totalDuration = rules.fold<int>(
        0,
        (sum, rule) => sum + rule.duration,
      );
      final cycleCount = totalElapsed ~/ totalDuration;
      final elapsedInCycle = totalElapsed % totalDuration;

      // 全周期增减
      for (final rule in rules) {
        amount += rule.rate * rule.duration * cycleCount;
      }

      // 当前周期内变化
      int accTime = 0;
      for (final rule in rules) {
        if (elapsedInCycle > accTime + rule.duration) {
          amount += rule.rate * rule.duration;
          accTime += rule.duration;
        } else {
          amount += rule.rate * (elapsedInCycle - accTime);
          break;
        }
      }
    }

    setState(() {
      _currentAmount = amount;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get formattedAmount =>
      NumberFormat("#,##0.00", "en_US").format(_currentAmount);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(imgPath, fit: BoxFit.cover, width: 365.w, height: 86.w),

          ///奖金池数字
          Positioned(
            top: 0,
            child: Container(
              margin: EdgeInsets.only(top: numberMarginTop),
              child: Align(
                alignment: Alignment.center,
                child: IntrinsicHeight(
                  child: buildGradientNumber(_currentAmount),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: textBgMarginBottom,
            child: Container(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              height: textBgHeight,
              width: scrollAxis == Axis.horizontal ? textBgMaxWidth : null,
              constraints:
                  scrollAxis == Axis.vertical
                      ? BoxConstraints(maxWidth: textBgMaxWidth)
                      : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Color(0xFFD9FF00).withValues(alpha: 0.21),
                  width: 1.w,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF810000),
                    Color(0xFF1B0000).withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: buildTextVerticalMarquee(
                textBgHeight,
                isOneLine: style != 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///垂直向上无限滚动
Widget buildTextVerticalMarquee(double textBgHeight, {bool? isOneLine}) {
  return VerticalMarqueePager(
    messages: [
      '玩家 Tia*** 提现1680元 玩家 Jak*** 提现5800元',
      '玩家 Lia*** 提现3200元 玩家 Pau*** 提现9800元',
      '玩家 Poo*** 提现7500元 玩家 lili*** 提现4500元',
      '玩家 Ken*** 提现2800元 玩家 Sun*** 提现1200元',
      '玩家 Ping*** 提现6000元 玩家 Che*** 提现8000元',
      '玩家 Ger*** 提现15000元 玩家 Chen*** 提现1800元',
      '玩家 Yan*** 提现11000元 玩家 Li*** 提现3000元',
      '玩家 Fly*** 提现5000元 玩家 Hoo*** 提现18000元',
      '玩家 Line*** 提现10000元 玩家 Fim*** 提现7000元',
      '玩家 Lin*** 提现2200元 玩家 Zho*** 提现6000元',
      '玩家 Dak*** 提现8000元 玩家 Tim*** 提现4000元',
      '玩家 Jun*** 提现13000元 玩家 Sun*** 提现9000元',
      '玩家 Wu*** 提现5500元 玩家 Re*** 提现1500元',
      '玩家 Jer*** 提现7700元 玩家 Xu*** 提现12400元',
      '玩家 Kai*** 提现1900元 玩家 Lin*** 提现8800元'
    ],
    height: textBgHeight,
    isOneLine: isOneLine,
  );
}
//
// ///文本跑马灯
// Widget buildTextMarquee() {
//   return Marquee(
//     text:
//         '1.玩家：tia*** 提现12690元刚刚 玩家：tia*** 提现12690元刚刚,2.玩家：tia*** 提现12690元刚刚 玩家：tia*** 提现12690元刚刚',
//     style: TextStyle(color: Colors.white, fontSize: 8.sp),
//     scrollAxis: Axis.horizontal,
//     crossAxisAlignment: CrossAxisAlignment.center,
//     blankSpace: 20.0,
//     velocity: 30.0,
//     pauseAfterRound: Duration(seconds: 1),
//     //startPadding: 10.0,
//     accelerationDuration: Duration(seconds: 1),
//     accelerationCurve: Curves.linear,
//     decelerationDuration: Duration(milliseconds: 1000),
//     decelerationCurve: Curves.easeOut,
//   );
// }

///动画翻转奖金池金额
Widget buildGradientNumber(double amount) {
  return ShaderMask(
    shaderCallback:
        (bounds) => const LinearGradient(
          colors: [Color(0xFFE8C979), Color(0xFFFFF9BC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds),
    blendMode: BlendMode.srcIn,
    child: AnimatedFlipCounter(
      duration: Duration(milliseconds: 500),
      //negativeSignDuration: const Duration(milliseconds: 150),
      value: double.parse(amount.toStringAsFixed(2)),
      fractionDigits: 2,
      thousandSeparator: ',',
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1,
      ),
    ),
  );
}

///垂直向上无限滚动文本
class VerticalMarqueePager extends StatefulWidget {
  final List<String> messages;
  final double? height;
  final bool? isOneLine;
  final Duration interval;
  VerticalMarqueePager({
    super.key,
    required this.messages,
    this.height,
    this.interval = const Duration(seconds: 3),
    this.isOneLine = true,
  });

  @override
  State<VerticalMarqueePager> createState() => _VerticalMarqueePagerState();
}

class _VerticalMarqueePagerState extends State<VerticalMarqueePager> {
  late ScrollController _scrollController;
  late Timer _timer;
  late double height;
  late bool isOneLine;
  @override
  void initState() {
    super.initState();
    height = widget.height ?? 32.w;
    _scrollController = ScrollController();
    _timer = Timer.periodic(widget.interval, (_) {
      if (_scrollController.hasClients) {
        final double singleItemHeight = height / 2; // 每行文字高度
        final double pageHeight =
            widget.isOneLine ?? true
                ? widget.height ?? singleItemHeight
                : singleItemHeight * 2;
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final nextOffset = _scrollController.offset + pageHeight;

        if (nextOffset >= maxScrollExtent) {
          _scrollController.jumpTo(0.1); // 避免直接 jumpTo(0) 不触发动画
          _scrollController.animateTo(
            pageHeight,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            nextOffset,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repeatedMessages = [...widget.messages, ...widget.messages]; // 用于循环滚动
    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: repeatedMessages.length ~/ 2,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final start = index * 2;
          final end =
              (start + 2 <= repeatedMessages.length)
                  ? start + 2
                  : repeatedMessages.length;
          final pageMessages = repeatedMessages.sublist(start, end);
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                pageMessages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final msg = entry.value;
                  return Container(
                    padding:
                        (widget.isOneLine ?? true)
                            ? null
                            : index == 0
                            ? EdgeInsets.only(top: 2.w, bottom: 2.w)
                            : EdgeInsets.zero,
                    height:
                        (widget.isOneLine ?? true) ? height : ((height) / 2),
                    child: Text(
                      msg,
                      style: TextStyle(fontSize: 8.sp, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
