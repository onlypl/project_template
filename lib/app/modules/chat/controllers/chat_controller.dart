import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:project_template/app/http/apis.dart';
import 'package:project_template/app/utils/log.dart';
import 'package:project_template/app/utils/progress_hud.dart';

import '../../../models/message_model.dart';
import '../../../webSocket/web_socket_manager.dart';

class ChatController extends GetxController {
  final RxString sendText = ''.obs;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listViewScrollController = ScrollController();

  final RxDouble bottomHeight = 0.0.obs;
  GlobalKey bottomKey = GlobalKey();
  late final WebSocketManager? websocket;
  late final String udid;
  RxList messageList = [].obs;
  late final String nickName;
  late double bottomPading;
  final FocusNode focusNode = FocusNode();
  RxBool keyboardVisible = false.obs;

  List<String> avatarList = [
    'https://img1.baidu.com/it/u=3598104138,3632108415&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800',
    'https://img2.baidu.com/it/u=1438832961,3549010781&fm=253&fmt=auto&app=120&f=JPEG?w=509&h=500',
    'http://img1.baidu.com/it/u=1461995691,1256211154&fm=253&app=138&f=JPEG?w=500&h=500',
    'http://img2.baidu.com/it/u=2057128861,1502176663&fm=253&app=138&f=JPEG?w=500&h=500',
    'http://img0.baidu.com/it/u=3028053320,3240632693&fm=253&app=138&f=JPEG?w=500&h=500',
    'https://img2.baidu.com/it/u=236792459,3410991851&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=500',
    'https://q6.itc.cn/q_70/images03/20250404/7b97b18860d74146ade89a76124786f9.jpeg',
    'https://q1.itc.cn/q_70/images03/20250316/f30c84c4d3fc4f90a72d5214a4790d92.png',
    'https://img2.baidu.com/it/u=2777830821,881535668&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://b0.bdstatic.com/750b81d6201df173a03bc86e0930d03b.jpg@h_1280',
    'https://img0.baidu.com/it/u=4010788487,18349872&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=500',
    'https://ww2.sinaimg.cn/mw690/008dHcm6gy1hw0lrwtikfj30og0wgjuh.jpg',
    'https://b0.bdstatic.com/9eb357bbe91ab41ed44b69145533fb06.jpg@h_1280',
    'http://t15.baidu.com/it/u=120172735,2308794211&fm=224&app=112&f=JPEG?w=500&h=500',
    'https://img2.baidu.com/it/u=361556200,3663058344&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1255',
    'https://img1.baidu.com/it/u=628656884,2387133836&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1361',
    'https://q4.itc.cn/q_70/images01/20240110/9e1edacc6d14401eb5ce5e67d3bbb423.jpeg',
    'https://pic.rmb.bdstatic.com/bjh/240527/beautify/d0267d48d982c323c3ae91475c19444a.jpeg@h_1280',
    'https://q8.itc.cn/q_70/images01/20240110/0aea56585a144d00af01797186c08f3b.jpeg',
    'http://img2.baidu.com/it/u=1636137972,967526262&fm=253&app=138&f=JPEG?w=800&h=1145',
  ];
  late final avatarUrl;
  @override
  Future<void> onInit() async {
    super.onInit();

    Random random = Random();
    int randomNumber = random.nextInt(20);
    avatarUrl = avatarList[randomNumber];

    bottomPading = Get.mediaQuery.padding.bottom;
    Log().info('message----$bottomPading');
    focusNode.addListener(_handleFocusChange);
    await FlutterUdid.udid.then((value) {
      udid = value;
    });
    nickName = Get.arguments['nickName'];

    ///监听底部高度变化
    textEditingController.addListener(() {
      final RenderBox renderBox =
          bottomKey.currentContext!.findRenderObject() as RenderBox;
      print('${bottomHeight.value}-----${renderBox.size.height}');
      if (bottomHeight.value != renderBox.size.height) {
        bottomHeight.value = renderBox.size.height;
        _scrollToBottom();
      }
    });
    websocket =
        WebSocketManager()
          ..initSocket(wsPath: APIs.wsUrl, isOpenHeartBeat: true)
          ..listen(
            messageCallback: (message) {
              // 延迟500毫秒，使listview进行滑动到底部
              // gotoListBottom();
              print('消息返回:$message');
              try {
                // 尝试解析JSON字符串
                var jsonString = jsonDecode(message);
                MessageModel model = MessageModel.fromJson(jsonString);
                if (model.type == 'join') {
                  ProgressHUD.hide();
                }
                if (model.type != 'send' && model.type != 'join') {
                  return;
                }
                if (udid.isNotEmpty && udid == model.uid) {
                  model.isMe = true;
                }
                messageList.add(model);
                Future.delayed(Duration(milliseconds: 800), () {
                  _scrollToBottom();
                });
              } catch (e) {
                // 捕获异常，解析失败，返回false
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              print('错误-----,$error');
              BotToast.showText(text: '请求服务器异常');
            },
            onDone: () {
              ProgressHUD.hide();
              Log().info('连接断开回调');
              if (!WebSocketManager().isDisconnectByUser) {
                //不是由用户断开的情况下
                ProgressHUD.showLoadingText('正在重连...');
              }
            },
          );
    Stream<String>? chatStream =
        (WebSocketManager()
              ..setNewStreamController(StreamControllerNameEnum.chatRoomPage))
            .streamControllerList?[StreamControllerNameEnum.chatRoomPage.name]
            ?.stream;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    ProgressHUD.hide();
    textEditingController.dispose();
    focusNode.removeListener(_handleFocusChange);
    focusNode.dispose(); // Don't forget to dispose the FocusNode!
    listViewScrollController.dispose();
    WebSocketManager().disconnect(isDisconnectByUser: true); //关闭聊天室
    super.onClose();
  }

  //弹出或者收起软键盘
  void _handleFocusChange() {
    keyboardVisible.value =
        focusNode.hasFocus; // Update the keyboard visibility state.
    Log().debug('执行(${keyboardVisible == true ? '弹出软键盘' : '收起软键盘'})');
    update();
    if (keyboardVisible.value) {
      Future.delayed(Duration(milliseconds: 800), () {
        _scrollToBottom();
      });
    }
  }

  /// 在合适的地方（比如发送按钮点击发送聊天消息）
  void sendChatMessage() {
    if (sendText.isNotEmpty) {
      WebSocketManager().sendMessage(
        message: jsonEncode(
          MessageModel(
            type: 'send',
            uid: udid,
            data: sendText.value,
            nickName: nickName,
            avatarUrl: avatarUrl,
          ),
        ),
        needDisplayMsg: false,
      );
      sendText.value = '';
      textEditingController.text = '';
      Get.focusScope?.unfocus();
      update();
    } else {
      Log().debug('请输入消息');
    }
  }

  //输入内容发生改变
  void changeSendText(String msg) {
    sendText.value = msg;
    update();
  }

  //滚动到最底部
  void _scrollToBottom() {
    if (listViewScrollController.hasClients) {
      var resp = listViewScrollController.animateTo(
        listViewScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }
}
