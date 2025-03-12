import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

import '../../config/app_colors.dart';
import '../../utils/log.dart';
import '../../utils/view_utils.dart';
import 'video_controls.dart';

///播放器组件
///      ? Icons.fullscreen_exit
//        : Icons.fullscreen,
final GlobalKey<_VideoViewState> videoKey = GlobalKey();

class VideoView extends StatefulWidget {
  final String url; //视频url
  final String? title; //视频标题
  final String? cover; //封面
  final bool autoPlay; //是否自动播放
  final bool looping; //是否循环播放
  final double aspectRatio; //宽/高缩放比例
  final Widget? overlayUI;
  final Widget? barrageUI; //弹幕UI
  final EdgeInsets? padding; //顶部问题
  final VoidCallback? completedCallback; //完成播放回调
  const VideoView({
    super.key,
    required this.url,
    this.cover,
    this.autoPlay = true,
    this.looping = false,
    this.aspectRatio = 16 / 9,
    this.overlayUI,
    this.barrageUI,
    this.padding,
    this.completedCallback,
    this.title,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _videoPlayerController; //video_plater播放器Controller
  ChewieController? _chewieController; //chewie播放器Controller
  //ConfigModel? configModel;
  bool isCompleted = false;
  //封面
  get _placeholder => FractionallySizedBox(
    widthFactor: 1,
    child: cachedImage(widget.cover ?? "", placeholderImg: Container()),
  );

  get _progressColors => ChewieProgressColors(
    playedColor: AppColor.themeColor, //已播放进度颜色
    handleColor: AppColor.themeColor, //进度按钮颜色
    backgroundColor: Colors.white, //底色
    bufferedColor: Colors.grey, //缓存进度颜色
  );

  @override
  void initState() {
    super.initState();
    getConfig();
    initializePlayer(widget.url, title: widget.title);
  }

  ///获取暂停播放广告
  Future<void> getConfig() async {
    // var ps = Storage();
    // await ps.getStorage(AppConstants.appConfig).then((value) {
    //   configModel = ConfigModel.fromJson(value);
    // });
  }

  ///初始化播放器
  Future<void> initializePlayer(String url, {String? title}) async {
    print('~~~~~~~${url}');
    isCompleted = false; //重置是否完成状态
    //初始化播放器设置
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    //    Uri.parse('https://v1.tlkqc.com/wjv1/202308/20/kN2Ynv9AS12/video/index.m3u8'));
    ///https://vjs.zencdn.net/v/oceans.mp4

    await _videoPlayerController?.initialize().then((value) {
      _createChewieController(title: title);
      _addVideoPlayerListener();
      setState(() {});
    });
  }

  void _addVideoPlayerListener() {
    _videoPlayerController?.addListener(() {
      VideoPlayerValue value = _videoPlayerController!.value;
      if (value.isPlaying) {
        //    Log().info('播放中');
      } else if (value.isBuffering) {
        //  Log().info('缓冲中');
      } else if (value.isCompleted && value.duration.inSeconds > 0) {
        if (isCompleted) {
          return;
        }
        isCompleted = true;
        Log().info('完成');
        if (widget.completedCallback != null) {
          widget.completedCallback!();
        }
      } else if (value.isInitialized) {
        // Log().info('初始化'); //初始化 完成 缓冲  完成
      }
    });
  }

  //初始化控制器
  void _createChewieController({String? title}) {
    if (_videoPlayerController == null) {
      return;
    }

    _chewieController = ChewieController(
      // allowedScreenSleep: true,
      videoPlayerController: _videoPlayerController!,
      aspectRatio: widget.aspectRatio, //比例
      //autoInitialize: true, //自动初始化
      looping: widget.looping, //加载
      autoPlay: widget.autoPlay, //自动播放
      hideControlsTimer: const Duration(seconds: 5),
      allowMuting: true, //是否显示禁音按钮
      allowPlaybackSpeedChanging: false, //是否显示倍速
      allowFullScreen: false, //是否左上角显示切换全屏
      placeholder: widget.cover != null ? _placeholder : Container(),
      //  isLive: true, //是否显示直播控制器
      customControls: VideoControls(
        title: title,
        // adUrl: configModel?.ads?.playerPause?.imgUrl, //暂停广告
        // showAd: configModel?.ads?.playerPause?.imgUrl == null ? false : true, //是否显示暂停广告
        backgroundColor: const Color.fromRGBO(41, 41, 41, 0.7),
        iconColor: const Color.fromARGB(255, 200, 200, 200),
      ),
      cupertinoProgressColors: _progressColors,
    );
    _chewieController?.addListener(_fullScreenListener); //全屏变化监听
  }

  ///切换视频
  Future<void> toggleVideo(String url, {String? title}) async {
    await _videoPlayerController?.pause();
    // widget.url = url;
    releaseResources();
    _videoPlayerController = null;
    _chewieController = null;
    setState(() {});
    await initializePlayer(url, title: title);
  }

  ///全屏切换竖屏监听
  void _fullScreenListener() {
    Size size = MediaQuery.of(context).size;
    if (size.width > size.height) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]); //
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    print('释放了');
    releaseResources();
    super.dispose();
  }

  void releaseResources() {
    _videoPlayerController?.pause();
    _chewieController?.removeListener(_fullScreenListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double playerHeight = 1.sw / widget.aspectRatio; //根据宽度和宽高比例获取高度
    return Container(
      padding: widget.padding,
      width: 1.sw,
      height: 1.sw / widget.aspectRatio,
      //  color: TvColor.black,
      child:
          _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  size: 30.w,
                  color: Colors.white,
                ),
              ),
    );
  }
}
