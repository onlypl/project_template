import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/base_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/base_web_controller.dart';

class BaseWebView extends GetView<BaseWebController> {
  const BaseWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          controller.isShowAppBar ? BaseAppBar(title: controller.title) : null,
      body: PopScope(
        //canPop: false, //手机返回键
        child: WebViewWidget(controller: controller.webViewController),
        onPopInvokedWithResult: (didPop, result) async {
          // if (didPop) {
          //   goBack();
          //   return;
          // }
        },
      ),
    );
  }

  ///本地html 富文本
  buildHtmlRichText({richText, Map<String, Style>? style}) {
    return ListView(
      children: [Html(data: controller.richText, style: style ?? {})],
    );
  }

  goBack() async {
    bool goBack = await controller.webViewController.canGoBack();
    if (goBack) {
      controller.webViewController!.goBack();
    } else {
      SystemNavigator.pop();
    }
  }
}
