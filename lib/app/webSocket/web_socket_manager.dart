import 'dart:async';
import 'dart:convert';

import 'package:project_template/app/models/message_model.dart';
import 'package:project_template/app/webSocket/stream_tool.dart';
import 'package:rxdart/subjects.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WebSocketMessageCallback = void Function(dynamic message);

/// 注册流控制器需要在哪些页面使用
///
/// 目前分三种类型：
/// 1.[customerLoginPage]游客模式下也就是在未登录时候（用户处于登录相关页面）
/// 2.[customerMainPage]用户已登录，处于主页及其他登录后的页面下
/// 3.[chatRoomPage]用户处在聊天室里（游客下的在线客服聊天室、用户已登录下的在线客服聊天室、买卖用户之间的聊天室）
enum StreamControllerNameEnum {
  customerLoginPage,
  customerMainPage,
  chatRoomPage,
}

class WebSocketManager {
  WebSocketManager._();

  static WebSocketManager? _singleton;

  factory WebSocketManager() => _singleton ??= WebSocketManager._();

  /// 用于连接websocket的链接uri
  Uri? wsUri;

  /// websocket连接后的对象
  WebSocketChannel? _webSocketChannel;

  /// 指定的stream流控制器存放map
  Map<String, BehaviorSubject<String>>? streamControllerList;

  /// 是否开启心跳
  bool isOpenHeartBeat = true;

  /// 用于控制心跳轮询
  StreamSubscription<String>? _subscription;

  /// 是否是用户主动触发关闭连接
  bool isDisconnectByUser = false;

  /// 另辟一个单独的消息回调函数
  WebSocketMessageCallback? messageCallback;

  /// 连接断开回调
  Function()? onDone;

  /// 连接出错回调
  Function? onError;

  /// step one - ex: ws://localhost:1234
  initSocket({required String wsPath, bool isOpenHeartBeat = true}) {
    if (_webSocketChannel != null) {
      print("socket实例已存在, 请勿重复创建");
      return;
    }

    // 自己项目中后端需要前端拼一个登录令牌用于控制后端逻辑处理，这里使用的是登录后的token
    var authorization = "登录后的token";
    wsUri = Uri.tryParse("$wsPath?Authorization=$authorization");
    // wsUri = Uri.tryParse(wsPath);
    if (wsUri == null) return;
    this.isOpenHeartBeat = isOpenHeartBeat;
    _connectWebSocket(isInitField: true);
  }

  /// [isRunForReConnect] 是否是由重连机制触发的此方法
  void _connectWebSocket({bool isInitField = false}) {
    _webSocketChannel = WebSocketChannel.connect(wsUri!);
    if (!isInitField) {
      isDisconnectByUser = false;
    }
  }

  /// step two - listen
  void listen({
    WebSocketMessageCallback? messageCallback,
    Function()? onDone,
    Function? onError,
  }) {
    if (_webSocketChannel == null) {
      return;
    }
    this.messageCallback = messageCallback;
    this.onDone = onDone;
    this.onError = onError;
    streamControllerList ??= <String, BehaviorSubject<String>>{
      // StreamControllerNameEnum.customerLoginPage.name: BehaviorSubject(),
      // StreamControllerNameEnum.customerMainPage.name: BehaviorSubject(),
      // StreamControllerNameEnum.chatRoomPage.name: BehaviorSubject()
    };

    // 监听一系列连接情况（如收到消息、onDone：连接关闭、onError：接连异常）
    _webSocketChannel?.stream.listen(
      (message) {
        print(
          "websocket onData message = ${message.toString()}, type = ${message.runtimeType}",
        );
        if (message is String && message.isEmpty) {
          // 消息为空（可能得情况：心跳 or another）
          return;
        }
        // 通过流控制器把消息分发出去，在需要的页面监听此流的消息
        streamControllerList?.forEach((key, value) {
          // print("key = $key, value.isClosed = ${value.isClosed}");
          if (!value.isClosed) {
            value.sink.add(message);
          }
        });
        this.messageCallback?.call(message);
      },
      onDone: () {
        print("websocket onDone ...");
        this.onDone?.call();
        // 掉线重连
        reConnect();
      },
      onError: (Object error, StackTrace stackTrace) {
        print(
          "websocket onError error = ${error.toString()}, stackTrace = ${stackTrace.toString()}",
        );
        //showToast(msg: "连接服务器失败!");
        this.onError?.call(error, stackTrace);
      },
      cancelOnError: false,
    );
    // 连接建立成功时的回调通知，可在此做心跳操作
    _webSocketChannel?.ready.then((value) {
      print("webSocket ready");
      isDisconnectByUser = false;
      if (isOpenHeartBeat) {
        // 收到连接成功的回馈，开始执行心跳操作
        _startHeartBeat();
      }
    });
  }

  /// 开启心跳  //type  = active
  void _startHeartBeat() {
    if (_subscription != null) {
      print("websocket startHeartBeat _subscription != null");
      return;
    }
    Future.delayed(const Duration(seconds: 30), () {
      var pollingStream = StreamTool().timedPolling(
        const Duration(seconds: 30),
        () => Future(() => ""),
        100000000,
      );
      //进行流内容监听
      //"heart beat"
      _subscription = pollingStream.listen((result) {
        sendMessage(
          message: jsonEncode(MessageModel(type: 'active', isMe: true)),
          needDisplayMsg: false,
        );
      });
    });
  }

  /// 发送消息 type uid
  void sendMessage({required String message, bool needDisplayMsg = true}) {
    print("websocket sendMessage message = $message");
    if (needDisplayMsg) {
      streamControllerList?.forEach((key, value) {
        if (!value.isClosed) {
          value.sink.add(message);
        }
      });
    }

    _webSocketChannel?.sink.add(message);
  }

  /// 掉线重连
  void reConnect() {
    if (isDisconnectByUser) return;
    Future.delayed(const Duration(seconds: 10), () {
      // disconnect();

      _subscription?.cancel();
      _subscription = null;
      _webSocketChannel?.sink.close(status.abnormalClosure, "掉线重连");
      _webSocketChannel = null;
      _connectWebSocket(isInitField: true);
      listen(
        messageCallback: messageCallback,
        onDone: onDone,
        onError: onError,
      );
    });
  }

  /// 断开连接并销毁
  void disconnect({bool isDisconnectByUser = false}) {
    this.isDisconnectByUser = isDisconnectByUser;
    isOpenHeartBeat = false;
    _subscription?.pause();
    _subscription?.cancel();
    _subscription = null;
    streamControllerList?.forEach((key, value) {
      value.close();
    });
    streamControllerList?.clear();
    streamControllerList = null;
    _webSocketChannel?.sink.close(status.normalClosure, "用户退出聊天界面，聊天关闭");
    _webSocketChannel = null;
  }

  /// 新建指定stream流控制器进行消息流回调
  setNewStreamController(StreamControllerNameEnum streamControllerName) {
    if (streamControllerList?.containsKey(streamControllerName.name) ?? false) {
      streamControllerList?[streamControllerName.name]?.close();
    }
    streamControllerList?[streamControllerName.name] = BehaviorSubject();
  }
}
