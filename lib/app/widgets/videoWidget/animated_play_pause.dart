import 'package:flutter/material.dart';

///播放/暂停隐式动画小部件
class AnimatedPlayPause extends StatefulWidget {
  const AnimatedPlayPause({
    super.key,
    required this.playing,
    this.size,
    this.color,
  });

  final double? size;
  final bool playing;
  final Color? color;

  @override
  State<StatefulWidget> createState() => AnimatedPlayPauseState();
}

class AnimatedPlayPauseState extends State<AnimatedPlayPause>
    with SingleTickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    value: widget.playing ? 1 : 0,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(AnimatedPlayPause oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedIcon(
        color: widget.color,
        size: widget.size,
        icon: AnimatedIcons.play_pause,
        progress: animationController,
      ),
    );
  }
}
