import 'package:flutter/material.dart';
import 'package:project_template/app/http/apis.dart';
import 'package:project_template/app/webSocket/web_socket_manager.dart';

class GlobalWebSocketVM extends ChangeNotifier {
  void startWebSocket() {
    WebSocketManager()
      ..initSocket(wsPath: APIs.wsUrl, isOpenHeartBeat: false)
      ..listen(
        messageCallback: (message) {
          // 延迟500毫秒，使listview进行滑动到底部
          // gotoListBottom();
        },
        onDone: () {},
      );
  }

  /// 获取socket实时数据流
  ///
  /// 每次都需要新绑定一个StreamController，避免数据流出现错乱情况
  Stream<String>? getMessageStream(
    StreamControllerNameEnum streamControllerName,
  ) =>
      (WebSocketManager()..setNewStreamController(streamControllerName))
          .streamControllerList?[streamControllerName.name]
          ?.stream;
}
