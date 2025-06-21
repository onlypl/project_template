// import 'dart:math';
//
// import 'package:filbet/app/modules/mine/vipCenter/controllers/vip_center_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// class ArcProgressBar extends StatefulWidget {
//   const ArcProgressBar({
//     super.key,
//   });
//
//   @override
//   State<ArcProgressBar> createState() => _ArcProgressBarState();
// }
//
// class _ArcProgressBarState extends State<ArcProgressBar> {
//   late double width;
//   late double height;
//   final VipCenterController controller = Get.find();
//
//   double startFixedProgress = 0.675;
//   double centerFixedProgress = 0.5;
//   double endFixedProgress = 0.33;
//
//   ///三个圆点的和文字位置进度点
//
//   RxDouble centerProgress = 0.5.obs;
//   RxDouble endProgress = (0.5 - 0.17).obs; //0.17
//
//   RxDouble end2Progress = (0.5 - 0.17 * 2).obs;
//
//   Rx<Offset> arcCenterOffset = Offset.zero.obs;
//   Rx<Offset> arcEndOffset = Offset.zero.obs;
//
//   Rx<Offset> arcEnd2Offset = Offset.zero.obs;
//   RxDouble progress = 0.0.obs;
//   RxList<Map<String, dynamic>> points = <Map<String, dynamic>>[].obs;
//   double range = 0.17; //固定值
//   Size size = Size.zero;
//   @override
//   void initState() {
//     super.initState();
//     width = 1.sw;
//     height = 340.w;
//     size = Size(width, height);
//     points.clear();
//     for (var i = 0; i < controller.levelDataList.length; i++) {
//       var levelMap = controller.levelDataList[i];
//       Map<String, dynamic> tempPoint = {};
//       tempPoint['arcOffset'] = getArcPoint(0.5 - 0.17 * i, size);
//       tempPoint['pointProgress'] = 0.5 - 0.17 * i;
//       tempPoint['bubbleColors'] = levelMap['bubbleColors'];
//       tempPoint['title'] = levelMap['title'];
//       points.add(tempPoint);
//       //range
//     }
//
//     //往前 page是< controller.currentPage.value
//     //往后 page是> controller.currentPage.value
//     controller.pageController.addListener(() {
//       var page = controller.pageController.page ?? 0.0;
//       if (controller.currentPage.value == 0) {
//         progress.value = page <= controller.currentPage.value + 1
//             ? page
//             : controller.currentPage.value + 1;
//       } else {
//         progress.value = page <= controller.currentPage.value + 1
//             ? page
//             : controller.currentPage.value + 1;
//       }
//       for (var i = 0; i < points.length; i++) {
//         var pointMap = points[i];
//         double tempProgress = 0;
//         if (i == 0) {
//           tempProgress = mapToScope(progress.value, 0.5 - 0.17 * i, 0.5 + 0.17);
//           pointMap['pointProgress'] = tempProgress;
//         } else {
//           tempProgress = mapToScope(
//               progress.value, 0.5 - 0.17 * (i), 0.5 - 0.17 * (i - 1));
//           pointMap['pointProgress'] = tempProgress;
//         }
//         pointMap['arcOffset'] = getArcPoint(tempProgress, size);
//       }
//     });
//   }
//
//   ///计算文本角度
//   double computeAngle({
//     required int index,
//     required double progress,
//     double maxValue = 0.3,
//   }) {
//     double delta = progress - index;
//
//     if (delta >= -0.5 && delta <= 0.5) {
//       return delta * (maxValue / 0.5); // [-0.5, 0.5] -> [-0.3, 0.3]
//     }
//
//     return delta > 0 ? maxValue : -maxValue;
//   }
//
//   ///计算透明度
//   double computeAlphaParabola({
//     required int index,
//     required double progress,
//     double minValue = 0.6,
//     double maxValue = 1.0,
//   }) {
//     double delta = progress - index;
//
//     ///print('$delta');
//     if (delta >= -0.5 && delta <= 0.5) {
//       // 抛物线公式：y = (max - min) * (1 - 4 * x^2) + min
//       // 使得 x = 0 时 y = max，x = ±0.5 时 y = min
//       return (maxValue - minValue) * (1 - 4 * delta * delta) + minValue;
//     }
//
//     return minValue;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return Container(
//         width: width,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // 弧线
//             Container(
//               // color: Colors.green,
//               child: CustomPaint(
//                 size: Size(width, height),
//                 painter: _ArcPainter(
//                     lineColor:
//                         controller.levelDataList[controller.currentPage.value]
//                             ['curvedLineColor']),
//               ),
//             ),
//
//             ...points.asMap().entries.map((entry) {
//               int index = entry.key;
//               var element = entry.value;
//               var arcOffset = element['arcOffset'];
//               var pointProgress = element['pointProgress'];
//               var bubbleColors = element['bubbleColors'];
//               return _buildPoint(arcOffset, index);
//             }),
//
//             ...points.asMap().entries.map((entry) {
//               int index = entry.key;
//               var element = entry.value;
//
//               Offset arcOffset = element['arcOffset'];
//               String title = element['title'];
//               var pointProgress = element['pointProgress'];
//               var bubbleColors = element['bubbleColors'];
//
//               return _buildRankTagBubble(arcOffset, bubbleColors, title, index);
//               return _buildText(arcOffset, title, index);
//             }),
//           ],
//         ),
//       );
//     });
//   }
//
//   ///根据位置绘制圆点
//   _buildPoint(Offset offset, int index) {
//     return Positioned(
//       left: offset.dx - 4.w,
//       top: offset.dy - 4.w,
//       child: Container(
//         width: 8.w,
//         height: 8.w,
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(
//               alpha: computeAlphaParabola(
//                   index: index,
//                   progress: progress.value,
//                   minValue: 0.6,
//                   maxValue: 0.0)),
//           borderRadius: BorderRadius.circular(4.r),
//           border: Border.all(
//             color: Colors.white.withValues(
//               alpha: computeAlphaParabola(
//                   index: index, progress: progress.value, minValue: 0.0),
//             ),
//             width: 2.w,
//           ),
//         ),
//       ),
//     );
//   }
//
//   ///等级气泡
//   _buildRankTagBubble(
//       Offset offset, List<Color> colors, String title, int index) {
//     List<Color> list = colors;
//     for (int i = 0; i < list.length; i++) {
//       Color tempColor = list[i];
//       double alpha = computeAlphaParabola(
//           index: index, progress: progress.value, minValue: 0.0, maxValue: 1);
//       list[i] = tempColor.withValues(alpha: alpha);
//     }
//     var width = measureTextWidth(
//             title,
//             TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.bold,
//             )) +
//         20.w;
//     return Positioned(
//       left: offset.dx - width / 2,
//       top: offset.dy + 6.w,
//       child: Transform.rotate(
//         angle: computeAngle(index: index, progress: progress.value),
//         child: RankTagBubble(
//           colors: list,
//           label: title,
//           width: width,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.white.withValues(
//               alpha: computeAlphaParabola(
//                   index: index, progress: progress.value, minValue: 0.6),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   ///根据位置绘制文本
//   _buildText(Offset offset, String title, int index) {
//     return Positioned(
//       left: offset.dx -
//           measureTextWidth(
//             title,
//             TextStyle(
//               fontSize: 14.sp / 2,
//               fontWeight: FontWeight.w400,
//             ),
//           ), // 根据你的坐标系调整
//       top: offset.dy + 12.sp, // 控制文字的位置
//       child: Transform.rotate(
//         angle: computeAngle(
//             index: index, progress: progress.value), // 文字倾斜角度（负值表示顺时针）
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.white.withValues(
//                 alpha: computeAlphaParabola(
//                     index: index, progress: progress.value, minValue: 0.6)),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ),
//     );
//   }
//
//   ///映射范围(如0.33-0.5)
//   ///value = (范围0.33-0.5)
//   ///min = 0.33 max = 0.5
//   double normalizeX(double value, double min, double max) {
//     return (value - min) / (max - min); // 范围映射为 0~1
//   }
//
//   ///映射范围(如0-1)
//   ///value = (范围0-1)
//   ///min = 0.33 max = 0.5
//   double mapToScope(double value, double min, double max) {
//     return min + (max - min) * value; // 范围映射为 0.33-0.5
//   }
//
//   ///计算文本宽度
//   double measureTextWidth(String text, TextStyle style) {
//     final textPainter = TextPainter(
//       text: TextSpan(text: text, style: style),
//       textDirection: TextDirection.ltr,
//     )..layout(); // 触发布局计算
//
//     return textPainter.width;
//   }
//
//   ///获取弧线位置
//   Offset getArcPoint(double progress, Size size) {
//     final radius = width + 100.w;
//     final center = Offset(size.width / 2, -180.w);
//
//     final startAngle = pi / 2 - pi / 3;
//     final sweepAngle = pi * 2 / 3;
//     final angle = startAngle + progress * sweepAngle;
//
//     final dx = center.dx + radius * cos(angle);
//     final dy = center.dy + radius * sin(angle);
//
//     return Offset(dx, dy);
//   }
// }
//
// ///画弧形
// class _ArcPainter extends CustomPainter {
//   final Color lineColor;
//
//   const _ArcPainter({
//     this.lineColor = Colors.white,
//   });
//   @override
//   void paint(Canvas canvas, Size size) {
//     // •	创建画笔对象 Paint
//     // •	设置渐变颜色从 amber → orangeAccent（左右方向渐变）
//     // •	设置绘制为线条模式（不是填充）
//     // •	设置线条宽度为 4
//     final paint = Paint()
//       ..shader = LinearGradient(
//         colors: [
//           lineColor.withValues(alpha: 0.2), // solid blue
//           lineColor.withValues(alpha: 0.4),
//           lineColor.withValues(alpha: 1),
//           lineColor.withValues(alpha: 1), // 30% opacity
//           lineColor, // solid blue
//           lineColor, // solid blue
//           lineColor.withValues(alpha: 1),
//           lineColor.withValues(alpha: 1), // 30% opacity
//           lineColor.withValues(alpha: 0.4),
//           lineColor.withValues(alpha: 0.2),
//         ],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4;
//     // •	圆的半径是组件宽度的 80%
//     // •	圆心在 widget 下方 +60 像素，使得只露出上半弧
//     final radius = 1.sw + 100.w; // size.width * 0.8;
//     // final center = Offset(size.width / 2, size.height + 60);
//     final center = Offset(size.width / 2, -180.w); // 👈 向上偏移圆心
//     //构造一个以 center 为圆心、radius 为半径的圆形边界区域
//     final rect = Rect.fromCircle(center: center, radius: radius);
//     // .绘制从 -π/2 - π/3（左上角开始）顺时针 2π/3（约 120°）的弧
//     // •	false 表示不是扇形（即不连接圆心）
//     //
//     // ⏱ 起始角度是 -120°，终点是 +60°，刚好对称形成一个底部的弧。
//     // canvas.drawArc(rect, -pi / 2 - pi / 3, pi * 2 / 3, false, paint);
//     // 👇 弧线从 60° 到 120°，也就是顶部圆弧
//     canvas.drawArc(rect, pi / 2 - pi / 3, pi * 2 / 3, false, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class RankTagBubble extends StatelessWidget {
//   final String label;
//   final double width;
//   final double height;
//   final List<Color> colors;
//   final TextStyle style;
//   const RankTagBubble({
//     Key? key,
//     required this.label,
//     required this.colors,
//     this.width = 68,
//     this.height = 20,
//     required this.style,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _BubblePainter(colors: colors),
//       child: Container(
//         alignment: Alignment.center,
//         width: width,
//         height: height,
//         child: Container(
//           padding: EdgeInsets.only(top: 6.w),
//           child: Text(
//             label,
//             style: style,
//             // style: TextStyle(
//             //   fontWeight: FontWeight.bold,
//             //   fontSize: 12.sp,
//             //   color: Colors.white,
//             // ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _BubblePainter extends CustomPainter {
//   final List<Color> colors;
//   const _BubblePainter({
//     required this.colors,
//   });
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..shader = LinearGradient(
//         colors: colors,
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..style = PaintingStyle.fill;
//
//     final radius = 6.0.r;
//     final tipWidth = 10.0.r;
//     final tipHeight = 4.0.r;
//
//     final path = Path()
//       ..moveTo(radius, 0)
//       ..lineTo((size.width - tipWidth) / 2, 0)
//       ..lineTo(size.width / 2, -tipHeight)
//       ..lineTo((size.width + tipWidth) / 2, 0)
//       ..lineTo(size.width - radius, 0)
//       ..quadraticBezierTo(size.width, 0, size.width, radius)
//       ..lineTo(size.width, size.height - radius)
//       ..quadraticBezierTo(
//           size.width, size.height, size.width - radius, size.height)
//       ..lineTo(radius, size.height)
//       ..quadraticBezierTo(0, size.height, 0, size.height - radius)
//       ..lineTo(0, radius)
//       ..quadraticBezierTo(0, 0, radius, 0)
//       ..close();
//
//     canvas.translate(0, tipHeight); // shift everything down to fit tip
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
