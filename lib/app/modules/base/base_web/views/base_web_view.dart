import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:project_template/app/widgets/base_appbar.dart';

//import 'package:webview_flutter/webview_flutter.dart';

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
        child: //buildAppWebView(),
            buildAppWebView(),

        onPopInvokedWithResult: (didPop, result) async {
          // if (didPop) {
          //   goBack();
          //   return;
          // }
        },
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
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
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

  // buildWebView() {
  //   return WebViewWidget(controller: controller.webViewController);
  // }

  // buildAppWebView() {
  //   return InAppWebView(
  //     key: controller.webViewKey,
  //     initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(controller.url))),
  //     initialSettings: InAppWebViewSettings(
  //       javaScriptEnabled: true,
  //       mediaPlaybackRequiresUserGesture: true,
  //       allowFileAccess: true,
  //       allowFileAccessFromFileURLs: true,
  //       allowUniversalAccessFromFileURLs: true,
  //       allowContentAccess: true,
  //       allowsInlineMediaPlayback: true,
  //       useShouldOverrideUrlLoading: true,
  //       useOnLoadResource: true,
  //       useOnDownloadStart: true,
  //       useHybridComposition: true,
  //     ),
  //     onWebViewCreated: (cont) {
  //       controller.inWebViewController = cont;
  //     },
  //     onLoadStart: (controller, url) {
  //       // EasyLoading.show(status: '加载中...');
  //     },
  //     // androidOnShowFileChooser: (controller, fileChooserParams) async {
  //     //   final result = await FilePicker.platform.pickFiles(); // 使用 file_picker 插件
  //     //   if (result != null && result.files.isNotEmpty) {
  //     //     final file = result.files.first;
  //     //     final uri = Uri.file(file.path!);
  //     //     return [uri];
  //     //   }
  //     //   return null;
  //     // },
  //     // androidOnShowFileChooser: (controller, fileChooserParams) async {
  //     //   final picker = ImagePicker();
  //     //   final XFile? file = await picker.pickImage(source: ImageSource.gallery);
  //     //   if (file == null) return [];
  //     //   final uri = Uri.file(file.path);
  //     //   return [uri];
  //     // },
  //   );
  // }

  ///本地html 富文本
  // buildHtmlRichText({richText, Map<String, Style>? style}) {
  //   return ListView(
  //     children: [Html(data: controller.richText, style: style ?? {})],
  //   );
  // }

  // goBack() async {
  //   bool goBack = await controller.webViewController.canGoBack();
  //   if (goBack) {
  //     controller.webViewController!.goBack();
  //   } else {
  //     SystemNavigator.pop();
  //   }
  // }
}
