import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/base_appbar.dart';

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
        child: buildAppWebView(),
        // WebViewWidget(controller: controller.webViewController),
        // onPopInvokedWithResult: (didPop, result) async {
        //   // if (didPop) {
        //   //   goBack();
        //   //   return;
        //   // }
        // },
      ),
    );
  }

  buildAppWebView() {
    return InAppWebView(
      key: controller.webViewKey,
      initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(controller.url))),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: true,
        allowFileAccess: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        allowContentAccess: true,
        allowsInlineMediaPlayback: true,
        useShouldOverrideUrlLoading: true,
        useOnLoadResource: true,
        useOnDownloadStart: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (cont) {
        controller.inWebViewController = cont;
      },
      // androidOnShowFileChooser: (controller, fileChooserParams) async {
      //   final picker = ImagePicker();
      //   final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      //   if (file == null) return [];
      //   final uri = Uri.file(file.path);
      //   return [uri];
      // },
    );
  }

  ///本地html 富文本
  buildHtmlRichText({richText, Map<String, Style>? style}) {
    return ListView(
      children: [Html(data: controller.richText, style: style ?? {})],
    );
  }

  // goBack() async {
  //   bool goBack = await controller.webViewController.canGoBack();
  //   if (goBack) {
  //     controller.webViewController!.goBack();
  //   } else {
  //     SystemNavigator.pop();
  //   }
  // }
}
