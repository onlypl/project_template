import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/cupertino/widgets/cupertino_options_dialog.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_template/app/widgets/videoWidget/video_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

import '../../utils/format_util.dart';
import '../../utils/log.dart';
import '../../utils/view_utils.dart';
import 'center_play_button.dart';

class VideoControls extends StatefulWidget {
  const VideoControls({
    required this.backgroundColor,
    required this.iconColor,
    this.showPlayButton = true,
    this.showAd = false,
    super.key,
    this.adUrl,
    this.title,
  });

  final Color backgroundColor;
  final Color iconColor;

  ///是否显示中间播放按钮
  final bool showPlayButton;
  final bool showAd; //是否显示广告
  final String? adUrl; //广告地址
  final String? title; //标题
  @override
  State<StatefulWidget> createState() {
    return _VideoControlsState();
  }
}

class _VideoControlsState extends State<VideoControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;

  ///[VideoPlayerValue] 是 [VideoPlayerController] 的持续时间、当前位置、缓冲状态、错误状态和设置
  late VideoPlayerValue _latestValue; //最新值
  ///音量最新值
  double? _latestVolume;

  ///隐藏控制层定时器
  Timer? _hideTimer;

  ///当前进度条是否处于拖拽状态
  bool _dragging = false;

  ///是否显示缓冲指示器
  bool _displayBufferingIndicator = false;

  ///顶部bar的内间距
  final topBarEdgeInsets = const EdgeInsets.only(top: 0, left: 0, right: 0);
  final marginSize = 5.0;
  Timer? _expandCollapseTimer;
  Timer? _initTimer;

  Duration? _subtitlesPosition;
  bool _subtitleOn = false;

  ///切换全屏定时器
  Timer? _bufferingDisplayTimer;

  double selectedSpeed = 1.0;
  late VideoPlayerController controller;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;
  ChewieController? _chewieController;

  late Offset startPosition; // 起始位置
  late double movePan; // 偏移量累计总和
  late double layoutWidth; // 组件宽度
  late double layoutHeight; // 组件高度
  String volumePercentage = ''; // 组件位移描述
  bool allowHorizontal = false; // 是否允许快进
  Duration position = const Duration(seconds: 0); // 当前时间
  double brightness = 0.0; //亮度
  bool brightnessOk = false; // 是否允许调节亮度
  Timer? _hideDialogTimer;

  ///隐藏时间
  bool showSettingDialog = true; //是否显示设置亮度/声音/快进提示
  double hintValue = 0.0; //显示亮度/音量进度
  int hintType = 0; // 0.亮度 1.音量 2.快进/快退
  bool isCloseAd = false; //是否关闭了广告

  bool _isClickPause = false; //是否点击里暂停

  @override
  void initState() {
    super.initState();

    ///内容隐藏/显示 hideStuff 为true 正在隐藏 false 正在显示
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    /////当前横竖屏 Orientation.landscape 为横屏，Orientation.portrait 为竖屏
    final orientation = MediaQuery.of(context).orientation;

    ///底部bar的高度 竖屏30 横屏 47
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;

    ///播放视频处于错误状态
    if (_latestValue.hasError) {
      ///有错误详细信息则展示详细信息
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder!(
            context,
            chewieController.videoPlayerController.value.errorDescription!,
          )
          ///没有详细信息则自定义
          : Stack(
            children: [
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Colors.white,
                      size: 42,
                    ),
                    Text('视频出错了~', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              ///返回按钮
              _buildBackButton(barHeight, true),
            ],
          );
    }
    final backgroundColor = widget.backgroundColor; //底部控制器组件背景色
    final iconColor = widget.iconColor; //图标颜色
    final showAd = widget.showAd; //是否显示广告

    ///按钮内间距
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        Log().info('鼠标进入该区域');
      },
      onExit: (PointerExitEvent event) {
        Log().info('鼠标退出该区域');
      },
      onHover: (PointerHoverEvent event) {
        print('鼠标悬停在该区域上');

        ///取消并重启隐藏控制层定时器
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        ///取消并重启隐藏控制层定时器
        onTap: () => _cancelAndRestartTimer(),
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onLongPress: () {
          //长按设置视频倍速2x
          controller.setPlaybackSpeed(2);
        },
        onLongPressUp: () {
          ///长按弹起恢复正常倍速
          controller.setPlaybackSpeed(1);
        },
        // onDoubleTap: () {
        //   ///双击暂停/播放
        //   controller.value.isPlaying ? controller.pause() : controller.play();
        // },

        ///AbsorbPointer 多组控件统一控制 阻止子控件接收指针事件
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: notifier.hideStuff, //true隐藏状态阻止子控件接收指针事件 false 允许
              child: Stack(
                children: [
                  ///缓冲状态～加载菊花...
                  if (_displayBufferingIndicator)
                    _chewieController?.bufferingBuilder?.call(context) ??
                        Stack(
                          children: [
                            const Center(child: CircularProgressIndicator()),

                            ///快进/音量/亮度提示
                            _buildHintText(),
                          ],
                        )
                  else
                    ///中间播放/暂停按钮
                    _buildHitArea(),

                  ///快进/音量/亮度提示
                  _buildHintText(),
                  //顶部 中间弹簧 底部
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ///顶部
                      _buildTopBar(barHeight),

                      //弹簧 填充最大间距
                      const Spacer(),
                      //底部字幕
                      if (_subtitleOn)
                        Transform.translate(
                          offset: Offset(
                            0.0,
                            notifier.hideStuff ? barHeight * 0.8 : 0.0,
                          ),
                          child: _buildSubtitles(chewieController.subtitle!),
                        ),

                      ///底部
                      _buildBottomBar(backgroundColor, iconColor, barHeight),
                    ],
                  ),
                ],
              ),
            ),

            //这里可以放暂停播放广告 并且要加条件 主动关闭则isClose = true 在_updateState方法里面判断isPlaying重置
            //并且不是播放完成才显示
            if ((!_latestValue.isPlaying &&
                    !_latestValue.isBuffering &&
                    _isClickPause &&
                    showAd) &&
                isCloseAd == false &&
                !((_latestValue.position >= _latestValue.duration) &&
                    _latestValue.duration.inSeconds > 0))
              _buildAd(),
          ],
        ),
      ),
    );
  }

  ///广告
  Widget _buildAd() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          setState(() {
            isCloseAd = true;
          });
          Log().info('广告');
        },
        child: Stack(
          children: [
            Container(
              //这里宽高要计算
              width: 200.w,
              height: 200.w / (3 / 2),
              child:
                  widget.adUrl != null
                      ? cachedImage(widget.adUrl!, isShowPlaceholderImg: false)
                      : null,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isCloseAd = true;
                  });
                  Log().info('点击关闭广告按钮');
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  child: Icon(Icons.clear, size: 24, color: Colors.white),
                  // child: Assets.images.common.closeAd.image(
                  //   width: 20,
                  //   height: 20,
                  // ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///快进/音量/亮度提示
  Widget _buildHintText() {
    return Offstage(
      offstage: showSettingDialog, //true为隐藏 false为显示
      child: Center(
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 20,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              hintType == 2
                  ? Text(
                    volumePercentage,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min, //设置Row宽度为自适应
                    children: [
                      if (hintType == 0)
                        Icon(Icons.brightness_4, size: 24, color: Colors.white)
                      // Assets.images.video.brightnessControl.image(
                      //   width: 24,
                      //   height: 24,
                      //   color: Colors.white,
                      // )
                      else if (hintType == 1)
                        Icon(
                          Icons.music_note_sharp,
                          size: 24,
                          color: Colors.white,
                        ),
                      // Assets.images.video.soundControl.image(
                      //   width: 24,
                      //   height: 24,
                      //   color: Colors.white,
                      // ),
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 5,
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(2.5),
                          value: hintValue,
                          backgroundColor: Colors.pink,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.red,
                            // backgroundColor: AppColor.themeColor2,
                            // valueColor: const AlwaysStoppedAnimation(
                            //   AppColor.themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  ///中间播放按钮
  Widget _buildHitArea() {
    ///是否播放结束 当前播放位置大于等于总的播放时间 并且  总的播放时间大于0
    final bool isFinished =
        (_latestValue.position >= _latestValue.duration) &&
        _latestValue.duration.inSeconds > 0;
    //是否显示中间播放按钮  当前显示中间按钮 并且 当前处于播放状态 并且 当前进度条不处于拖拽状态
    final bool showPlayButton =
        widget.showPlayButton && !_latestValue.isPlaying && !_dragging;
    return GestureDetector(
      ///点击:状态：播放中 则 取消并重新启动隐藏控制层计时器 否则状态：暂停播放  执行 取消隐藏定时器 并 显示控制层
      onTap:
          _latestValue.isPlaying
              ? _cancelAndRestartTimer
              : () {
                // 取消隐藏控制层定时器并显示控制层
                Log().info('取消定时器，显示控制层');
                _hideTimer?.cancel();
                setState(() {
                  notifier.hideStuff = false;
                });
              },
      child: CenterPlayButton(
        backgroundColor: widget.backgroundColor,
        iconColor: widget.iconColor,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: _playPause,
      ),
    );
  }

  ///顶部bar
  ///barHeight 高度
  Widget _buildTopBar(double barHeight) {
    return Container(
      height: barHeight,
      margin: topBarEdgeInsets,
      decoration:
          notifier.hideStuff
              ? BoxDecoration()
              : BoxDecoration(gradient: blackLinearGradient(fromTop: true)),
      child: Row(
        children: <Widget>[
          _buildBackButton(barHeight, false), //返回按钮
          chewieController.isFullScreen
              ? _buildTitle()
              :
              //弹簧距离最大值
              const Spacer(),
          _buildPictureButton(), //画中画
          _buildMoreButton(), //更多
        ],
      ),
    );
  }

  ///返回按钮
  _buildBackButton(double barHeight, bool isError) {
    return InkWell(
      onTap: _onBackCollapse,
      child: AnimatedOpacity(
        opacity:
            isError
                ? 1.0
                : notifier.hideStuff
                ? 0.0
                : 1.0,

        ///透明度 隐藏则是0
        duration: const Duration(milliseconds: 300), //动画时长
        child: Container(
          width: 48,
          height: barHeight,
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
          // child: Assets.images.common.back.image(
          //   width: 24,
          //   height: 24,
          //   color: Colors.white,
          // ),
        ),
      ),
    );
  }

  ///返回按钮事件
  void _onBackCollapse() {
    setState(() {
      notifier.hideStuff = true;
      if (chewieController.isFullScreen) {
        chewieController.exitFullScreen(); //退出全屏
      } else {
        Navigator.pop(context);
      }
    });
  }

  ///标题
  Widget _buildTitle() {
    return Expanded(
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,

        ///透明度 隐藏则是0
        duration: const Duration(milliseconds: 300), //动画时长
        child: Container(
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            widget.title ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  ///画中画
  _buildPictureButton() {
    return InkWell(
      onTap: () {},
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,

        ///透明度 隐藏则是0
        duration: const Duration(milliseconds: 300), //动画时长
        child: Container(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Icon(
            Icons.video_collection_outlined,
            size: 18,
            color: Colors.white,
          ),
          // child: Assets.images.video.pictureInPicture.image(
          //   width: 18,
          //   height: 18,
          //   color: Colors.white,
          // ),
        ),
      ),
    );
  }

  ///更多
  _buildMoreButton() {
    return InkWell(
      onTap: () {},
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,

        ///透明度 隐藏则是0
        duration: const Duration(milliseconds: 300), //动画时长
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(left: 4.0, right: 12.0),
          child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  ////底部视频控制
  Widget _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return SafeArea(
      bottom: chewieController.isFullScreen,
      minimum: chewieController.controlsSafeAreaMinimum,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.bottomCenter, //底部
          margin: EdgeInsets.only(top: 5.h),
          child:
          // BackdropFilter(
          //   filter: ui.ImageFilter.blur(
          //     sigmaX: 10.0,
          //     sigmaY: 10.0,
          //   ),
          //   child:
          Container(
            height: barHeight,
            color: backgroundColor,
            child:
                chewieController.isLive
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ///左边播放暂停按钮
                        _buildPlayPause(controller, iconColor, barHeight),

                        ///右边直播Live样式
                        _buildLive(iconColor),
                      ],
                    )
                    : Row(
                      children: [
                        ///播放暂停按钮
                        _buildPlayPause(controller, iconColor, barHeight),

                        ///当前进度时间
                        _buildPosition(iconColor),

                        ///进度条
                        _buildProgressBar(),

                        ///总时间
                        _buildRemaining(iconColor),

                        ///倍速按钮
                        // if (chewieController.allowPlaybackSpeedChanging)
                        //   _buildSpeedButton(controller, iconColor, barHeight),
                        _buildExpandButton(iconColor, barHeight),

                        ///底部右边其它按钮
                        if (chewieController.additionalOptions != null &&
                            chewieController
                                .additionalOptions!(context)
                                .isNotEmpty)
                          _buildOptionsButton(iconColor, barHeight),
                      ],
                    ),
          ),
          //  ),
        ),
      ),
    );
  }

  ///底部播放/暂停
  Widget _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return InkWell(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
        child:
            controller.value.isPlaying
                ? Icon(Icons.pause, size: 18, color: iconColor)
                : Icon(Icons.play_circle, size: 18, color: iconColor),
        //controller.value.isPlaying
        //     ? Assets.images.video.pause.image(
        //       width: 18,
        //       height: 18,
        //       color: iconColor,
        //     )
        //     : Assets.images.video.play.image(
        //       width: 18,
        //       height: 18,
        //       color: iconColor,
        //     ),

        //// AnimatedPlayPause(
        // //   color: widget.iconColor,
        // //   playing: controller.value.isPlaying,
        // // ),
      ),
    );
  }

  ///是否是直播底部tabbar
  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text('LIVE', style: TextStyle(color: iconColor, fontSize: 12.0)),
    );
  }

  ///当前进度时间
  Widget _buildPosition(Color iconColor) {
    final position = _latestValue.position;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
          fontFeatures: const [FontFeature.tabularFigures()],
        ), //字体等宽
      ),
    );
  }

  ///总时间
  Widget _buildRemaining(Color iconColor) {
    //final position = _latestValue.duration - _latestValue.position; //总时间逐步减少
    final position = _latestValue.duration;
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Text(
        '${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  ///进度条
  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: VideoProgressBar(
          controller,
          onDragStart: () {
            setState(() {
              _dragging = true;
            });

            _hideTimer?.cancel();
          },
          onDragUpdate: (timeStr) {
            setState(() {
              volumePercentage =
                  '${timeStr.split('.').first} / ${formatDateInt(controller.value.duration.inMilliseconds)}';
              hintType = 2;
              showSettingDialog = false; //显示进度
            });
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            setState(() {
              _dragging = false;
            });
            _startHideDialogTimer(milliseconds: 1000);
            _startHideTimer();
          },
          colors:
              chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
                playedColor: const Color.fromARGB(120, 255, 255, 255),
                handleColor: const Color.fromARGB(255, 255, 255, 255),
                bufferedColor: const Color.fromARGB(60, 255, 255, 255),
                backgroundColor: const Color.fromARGB(20, 255, 255, 255),
              ),
          draggableProgressBar: chewieController.draggableProgressBar,
        ),
      ),
    );
  }

  ///切换全屏
  InkWell _buildExpandButton(Color iconColor, double barHeight) {
    return InkWell(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight + (chewieController.isFullScreen ? 15.0 : 0),
          margin: const EdgeInsets.only(right: 0.0),
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
            child:
                chewieController.isFullScreen
                    ? Icon(
                      Icons.tablet_mac_sharp,
                      color: Colors.white,
                      size: 20,
                    )
                    : Icon(Icons.tablet_sharp, color: Colors.white, size: 20),
            //
            //   Assets.images.video.fullscreenExit.image(
            //   width: 20,
            //   height: 20,
            //   color: Colors.white,
            // )
            // : Assets.images.video.fullscreen.image(
            //   width: 20,
            //   height: 20,
            //   color: Colors.white,
            // ),

            // // Icon(
            //  //   chewieController.isFullScreen
            //  //       ? Icons.fullscreen_exit
            // //       : Icons.fullscreen,
            //  //   color: Colorshite,
            //  // ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////
  ///点击事件: 播放/暂停
  void _playPause() {
    ///是否播放结束 当前播放位置大于等于总的播放时间 并且  总的播放时间大于0
    final isFinished =
        _latestValue.position >= _latestValue.duration &&
        _latestValue.duration.inSeconds > 0;
    setState(() {
      ///播放中
      if (controller.value.isPlaying) {
        notifier.hideStuff = false; //显示控制层
        _hideTimer?.cancel(); //取消定时器
        controller.pause(); //暂停视频播放
        _isClickPause = true;
      } else {
        ///暂停中
        //取消并重新启动隐藏控制层计时器
        _cancelAndRestartTimer();
        //视频是否已加载并准备播放状态
        if (!controller.value.isInitialized) {
          ///加载视频并在加载完成后播放
          controller.initialize().then((_) {
            controller.play();
            _isClickPause = false;
          });
        } else {
          //判断视频是否已播放完成 完成则从头开始播放
          if (isFinished) {
            //设置播放位置
            // showAd = false;
            controller.seekTo(Duration.zero);
            controller.play();
            _isClickPause = false;
          } else {
            //未播放完成 则 直接播放
            controller.play();
            _isClickPause = false;
          }
        }
      }
    });
  }

  ///全屏按钮
  void _onExpandCollapse() {
    setState(() {
      notifier.hideStuff = true;
      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  ///取消并重新启动隐藏控制层计时器
  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    setState(() {
      //显示控制层
      notifier.hideStuff = false;
      _startHideTimer();
    });
  }

  ///启动隐藏控制层定时器
  void _startHideTimer() {
    //如果为负数则隐藏时间为默认的3秒否则为hideControlsTimer
    final hideControlsTimer =
        chewieController.hideControlsTimer.isNegative
            ? ChewieController.defaultHideControlsTimer
            : chewieController.hideControlsTimer;

    ///开启定时器
    _hideTimer = Timer(hideControlsTimer, () {
      setState(() {
        ///隐藏控制层
        notifier.hideStuff = true;
      });
    });
  }

  ///依赖关系发生变化
  @override
  void didChangeDependencies() {
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  ///初始化
  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;

    ///videoPlayer监听
    controller.addListener(_updateState);

    _updateState();

    ///播放状态/自动播放
    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    ///初始化时是否显示控件
    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          notifier.hideStuff = false;
        });
      });
    }
  }

  ///修改状态
  void _updateState() {
    if (!mounted) return;

    // 如果已设置缓冲延迟，则仅在缓冲延迟后显示进度条指示器
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      if (controller.value.isPlaying) {
        isCloseAd = false;
      }
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }

  ///缓冲定时器超时
  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  ///底部字幕 Subtitles: index下标  start开始时间位置 end结束时间位置
  Widget _buildSubtitles(Subtitles subtitles) {
    if (!_subtitleOn) {
      return const SizedBox();
    }
    if (_subtitlesPosition == null) {
      return const SizedBox();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition!);
    if (currentSubtitle.isEmpty) {
      return const SizedBox();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: marginSize, right: marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0x96000000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  ///底部右边其它按钮 更多
  GestureDetector _buildOptionsButton(Color iconColor, double barHeight) {
    final options = <OptionItem>[];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return GestureDetector(
      onTap: () async {
        _hideTimer?.cancel();

        if (chewieController.optionsBuilder != null) {
          await chewieController.optionsBuilder!(context, options);
        } else {
          await showCupertinoModalPopup<OptionItem>(
            context: context,
            semanticsDismissible: true,
            useRootNavigator: chewieController.useRootNavigator,
            builder:
                (context) => CupertinoOptionsDialog(
                  options: options,
                  cancelButtonText:
                      chewieController.optionsTranslation?.cancelButtonText,
                ),
          );
          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        }
      },
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        margin: const EdgeInsets.only(right: 6.0),
        child: Icon(Icons.more_vert, color: iconColor, size: 18),
      ),
    );
  }

  ///当前亮度
  Future<double> get currentBrightness async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      print(e);
      throw 'Failed to get current brightness';
    }
  }

  ///设置亮度
  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }

  ///垂直左边/右边触摸开始 ---亮度/声音
  void _onVerticalDragStart(details) async {
    _reset(context);
    startPosition = details.globalPosition;
    if (startPosition.dx < (layoutWidth / 2)) {
      /// 左边触摸
      // brightness = await Screen.brightness;
      try {
        brightness = await ScreenBrightness().current;
        print("当前亮度${brightness.toString()}");
      } catch (e) {
        print('Failed to get current brightness');
      }
      brightnessOk = true;
    }
  }

  ///垂直左边/右边触摸更新 ---亮度/声音
  void _onVerticalDragUpdate(details) {
    if (!controller.value.isInitialized) {
      return;
    }

    /// 累计计算偏移量(下滑减少百分比，上滑增加百分比)
    movePan += (-details.delta.dy);
    print(
      "偏移量/整体高度${movePan.toString()}${(movePan / layoutHeight).toString()}",
    );
    if (startPosition.dx < (layoutWidth / 2)) {
      /// 左边触摸
      if (brightnessOk = true) {
        setState(() {
          var value = _setBrightnessValue();
          volumePercentage = '亮度：${(value * 100).toInt()}%';
          hintValue = value;
          hintType = 0;
          print("1现在的亮度值${volumePercentage}");
          showSettingDialog = false; //显示进度
        });
      }
    } else {
      /// 右边触摸
      setState(() {
        var value = _setVerticalValue(num: 2);
        volumePercentage = '音量：${(value * 100).toInt()}%';
        hintValue = value;
        hintType = 1;
        print("2现在的音量值1${volumePercentage}");
        showSettingDialog = false; //显示进度
      });
    }
  }

  ///垂直左边/右边触摸更新 ---亮度/声音
  void _onVerticalDragEnd(_) async {
    if (!controller.value.isInitialized) {
      return;
    }
    if (startPosition.dx < (layoutWidth / 2)) {
      if (brightnessOk) {
        try {
          //SystemChrome.setScreenBrightness();
          await ScreenBrightness().setScreenBrightness(_setBrightnessValue());
        } catch (e) {
          print('Failed to set brightness');
        }
        brightnessOk = false;
        // 左边触摸
        _startHideDialogTimer();
      }
    } else {
      // 右边触摸
      await controller.setVolume(_setVerticalValue());
      _startHideDialogTimer();
    }
  }

  ///设置亮度
  double _setBrightnessValue() {
    // 亮度百分控制
    double value =
    //toStringAsFixed保留两位小数点
    double.parse((movePan / layoutHeight + brightness).toStringAsFixed(2));
    if (value >= 1.00) {
      value = 1.00;
    } else if (value <= 0.00) {
      value = 0.00;
    }
    return value;
  }

  //声音/亮度设置
  double _setVerticalValue({int num = 1}) {
    // 声音亮度百分控制
    double value = double.parse(
      (movePan / layoutHeight + controller.value.volume).toStringAsFixed(num),
    );
    if (value >= 1.0) {
      value = 1.0;
    } else if (value <= 0.0) {
      value = 0.0;
    }
    print("音量大小${value}");
    return value;
  }

  ///重置
  void _reset(BuildContext context) {
    startPosition = const Offset(0, 0);
    movePan = 0;
    layoutHeight = context.size!.height;
    layoutWidth = context.size!.width;
    volumePercentage = '';
  }

  ///横向触摸开始 -- 快进/快退
  void _onHorizontalDragStart(DragStartDetails details) async {
    _reset(context);
    if (!controller.value.isInitialized) {
      return;
    }
    // 获取当前时间
    position = controller.value.position;
    // 暂停成功后才允许快进手势
    allowHorizontal = true;
  }

  ///横向触摸更新 -- 快进/快退
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!controller.value.isInitialized && !allowHorizontal) {
      return;
    }
    // 累计计算偏移量
    movePan += details.delta.dx / 2;
    // double value = _setHorizontalValue();
    String currentSecond = formatDateInt(
      (movePan.floor() * 1000 + controller.value.position.inMilliseconds)
          .toInt(),
    );
    // _latestValue.duration
    setState(() {
      volumePercentage =
          '$currentSecond / ${formatDateInt(controller.value.duration.inMilliseconds)}';
      hintType = 2;
      showSettingDialog = false; //显示进度
    });
  }

  ///横向触摸结束 -- 快进/快退
  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (!controller.value.isInitialized && !allowHorizontal) {
      return;
    }
    //double value = _setHorizontalValue();
    int current =
        (movePan.floor() * 1000 + controller.value.position.inMilliseconds)
            .toInt();
    await controller.seekTo(Duration(milliseconds: current));
    allowHorizontal = false;
    _startHideDialogTimer();
  }

  ///设置快进/快退
  double _setHorizontalValue() {
    // 进度条百分控制
    double valueHorizontal = double.parse(
      (movePan / layoutWidth).toStringAsFixed(2),
    );
    // 当前进度条百分比
    double currentValue =
        position.inMilliseconds / controller.value.duration.inMilliseconds;
    double value = double.parse(
      (currentValue + valueHorizontal).toStringAsFixed(2),
    );
    print(
      "偏移量${movePan},偏移百分比${movePan / layoutWidth},进度条不知道什么参数${controller.value.duration.inMilliseconds}进度条百分比${position.inMilliseconds / controller.value.duration.inMilliseconds},value${value}",
    );
    if (value >= 1.00) {
      value = 1.00;
    } else if (value <= 0.00) {
      value = 0.00;
    }
    return value;
  }

  ///取消并多久后隐藏
  void _startHideDialogTimer({int milliseconds = 700}) {
    _hideDialogTimer?.cancel();

    ///开启隐藏定时器
    _hideDialogTimer = Timer(Duration(milliseconds: milliseconds), () {
      setState(() {
        ///隐藏进度
        showSettingDialog = true;
      });
    });
  }
}

//
//   ///声音开关按钮
//   GestureDetector _buildMuteButton(
//     VideoPlayerController controller,
//     Color backgroundColor,
//     Color iconColor,
//     double barHeight,
//     double buttonPadding,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         _cancelAndRestartTimer();
//
//         if (_latestValue.volume == 0) {
//           controller.setVolume(_latestVolume ?? 0.5);
//         } else {
//           _latestVolume = controller.value.volume;
//           controller.setVolume(0.0);
//         }
//       },
//       child: AnimatedOpacity(
//         opacity: notifier.hideStuff ? 0.0 : 1.0,
//         duration: const Duration(milliseconds: 300),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10.0),
//           child: BackdropFilter(
//             filter: ui.ImageFilter.blur(sigmaX: 10.0),
//             child: ColoredBox(
//               color: backgroundColor,
//               child: Container(
//                 height: barHeight,
//                 padding: EdgeInsets.only(
//                   left: buttonPadding,
//                   right: buttonPadding,
//                 ),
//                 child: Icon(
//                   _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
//                   color: iconColor,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   ///字幕按钮
//   Widget _buildSubtitleToggle(Color iconColor, double barHeight) {
//     //if don't have subtitle hiden button
//     if (chewieController.subtitle?.isEmpty ?? true) {
//       return const SizedBox();
//     }
//     return GestureDetector(
//       onTap: _subtitleToggle,
//       child: Container(
//         height: barHeight,
//         color: Colors.transparent,
//         margin: const EdgeInsets.only(right: 10.0),
//         padding: const EdgeInsets.only(
//           left: 6.0,
//           right: 6.0,
//         ),
//         child: Icon(
//           Icons.subtitles,
//           color: _subtitleOn ? iconColor : Colors.grey[700],
//           size: 16.0,
//         ),
//       ),
//     );
//   }
//
//   void _subtitleToggle() {
//     setState(() {
//       _subtitleOn = !_subtitleOn;
//     });
//   }
//
//   ///后退15秒
//   GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
//     return GestureDetector(
//       onTap: _skipBack,
//       child: Container(
//         height: barHeight,
//         color: Colors.transparent,
//         margin: const EdgeInsets.only(left: 10.0),
//         padding: const EdgeInsets.only(
//           left: 6.0,
//           right: 6.0,
//         ),
//         child: Icon(
//           CupertinoIcons.gobackward_15,
//           color: iconColor,
//           size: 18.0,
//         ),
//       ),
//     );
//   }
//
// //前进15秒
//   GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
//     return GestureDetector(
//       onTap: _skipForward,
//       child: Container(
//         height: barHeight,
//         color: Colors.transparent,
//         padding: const EdgeInsets.only(
//           left: 6.0,
//           right: 8.0,
//         ),
//         margin: const EdgeInsets.only(
//           right: 8.0,
//         ),
//         child: Icon(
//           CupertinoIcons.goforward_15,
//           color: iconColor,
//           size: 18.0,
//         ),
//       ),
//     );
//   }
//
//   ///倍速按钮
//   GestureDetector _buildSpeedButton(
//     VideoPlayerController controller,
//     Color iconColor,
//     double barHeight,
//   ) {
//     return GestureDetector(
//       onTap: () async {
//         _hideTimer?.cancel();
//
//         final chosenSpeed = await showCupertinoModalPopup<double>(
//           context: context,
//           semanticsDismissible: true,
//           useRootNavigator: chewieController.useRootNavigator,
//           builder: (context) => _PlaybackSpeedDialog(
//             speeds: chewieController.playbackSpeeds,
//             selected: _latestValue.playbackSpeed,
//           ),
//         );
//
//         if (chosenSpeed != null) {
//           controller.setPlaybackSpeed(chosenSpeed);
//
//           selectedSpeed = chosenSpeed;
//         }
//
//         if (_latestValue.isPlaying) {
//           _startHideTimer();
//         }
//       },
//       child: Container(
//         height: barHeight,
//         color: Colors.transparent,
//         padding: const EdgeInsets.only(
//           left: 6.0,
//           right: 8.0,
//         ),
//         margin: const EdgeInsets.only(
//           right: 8.0,
//         ),
//         child: Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.skewY(0.0)
//             ..rotateX(math.pi)
//             ..rotateZ(math.pi * 0.8),
//           child: Icon(
//             Icons.speed,
//             color: iconColor,
//             size: 18.0,
//           ),
//         ),
//       ),
//     );
//   }
//

//

//
//   ///后退15秒事件
//   Future<void> _skipBack() async {
//     _cancelAndRestartTimer();
//     final beginning = Duration.zero.inMilliseconds;
//     final skip =
//         (_latestValue.position - const Duration(seconds: 15)).inMilliseconds;
//     await controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));
//     // Restoring the video speed to selected speed
//     // A delay of 1 second is added to ensure a smooth transition of speed after reversing the video as reversing is an asynchronous function
//     Future.delayed(const Duration(milliseconds: 1000), () {
//       controller.setPlaybackSpeed(selectedSpeed);
//     });
//   }
//
//   ///前进15秒事件
//   Future<void> _skipForward() async {
//     _cancelAndRestartTimer();
//     final end = _latestValue.duration.inMilliseconds;
//     final skip =
//         (_latestValue.position + const Duration(seconds: 15)).inMilliseconds;
//     await controller.seekTo(Duration(milliseconds: math.min(skip, end)));
//     // Restoring the video speed to selected speed
//     // A delay of 1 second is added to ensure a smooth transition of speed after forwarding the video as forwaring is an asynchronous function
//     Future.delayed(const Duration(milliseconds: 1000), () {
//       controller.setPlaybackSpeed(selectedSpeed);
//     });
//   }
//

//
// ///弹出倍速选择弹窗
// class _PlaybackSpeedDialog extends StatelessWidget {
//   const _PlaybackSpeedDialog({
//     required List<double> speeds,
//     required double selected,
//   })  : _speeds = speeds,
//         _selected = selected;
//
//   final List<double> _speeds;
//   final double _selected;
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedColor = CupertinoTheme.of(context).primaryColor;
//
//     return CupertinoActionSheet(
//       actions: _speeds
//           .map(
//             (e) => CupertinoActionSheetAction(
//               onPressed: () {
//                 Navigator.of(context).pop(e);
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (e == _selected)
//                     Icon(Icons.check, size: 20.0, color: selectedColor),
//                   Text(e.toString()),
//                 ],
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }
// }
