import 'dart:async';

typedef FutureGenerator<T> = Future<T> Function();

///轮询工具类
class StreamTool {
  /// interval 轮询时间间隔
  /// maxCount 最大轮询数
  Stream<T> timedPolling<T>(
    Duration interval,
    FutureGenerator<T> future, [
    int maxCount = 1,
  ]) {
    StreamController<T>? controller;
    int counter = 0;
    bool polling = true;

    void stopTimer() {
      polling = false;
    }

    void tick() async {
      counter++;
      T result = await future();
      if (controller != null && !controller.isClosed) {
        controller.add(result);
      }
      if (counter == maxCount) {
        stopTimer();
        controller?.close();
      } else if (polling) {
        Future.delayed(interval, tick);
      }
    }

    void startTimer() {
      polling = true;
      tick();
    }

    //StreamSubscription调用pause，cancel时，stream里面的轮询也能响应暂停或取消
    controller = StreamController<T>(
      onListen: startTimer,
      onPause: stopTimer,
      onResume: startTimer,
      onCancel: stopTimer,
    );

    return controller.stream;
  }
}
