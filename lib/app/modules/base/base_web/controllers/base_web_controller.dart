import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BaseWebController extends GetxController {
  late String title = '';
  late String url = '';
  late WebViewController webViewController;
  late String richText = '';
  late bool isLocalUrl = false;
  late bool isShowAppBar = true;
  @override
  void onInit() {
    super.onInit();
    title = Get.arguments['title'] ?? '';
    url = Get.arguments['url'] ?? '';
    richText = Get.arguments['richText'] ?? '';
    isLocalUrl = Get.arguments['isLocalUrl'] ?? false;
    isShowAppBar = Get.arguments['isShowAppBar'] ?? true;
    intWebController();
  }

  void intWebController() {
    EasyLoading.show(status: '加载中...');
    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: ((progress) {
                ///更新加载进度
              }),
              onPageStarted: ((url) {
                ///开始加载
                // webViewController.clearCache();
              }),
              onPageFinished: ((url) {
                ///加载完成
                if (isLocalUrl) {
                  // //加载js文件
                  // String jsContent = rootBundle.loadString(jsPath);
                  // webViewController.runJavaScript(jsContent);
                  //js脚本
                  // webViewController
                  //     .runJavaScriptReturningResult("setname(pl)")
                  //     .then((value) {
                  //       print(value);
                  //     });
                }
                EasyLoading.dismiss();
              }),
              onWebResourceError: ((WebResourceError error) {
                ///加载失败
                EasyLoading.dismiss();
              }),

              ///拦截请求
              onNavigationRequest: ((NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              }),
              onHttpError: ((HttpResponseError response) {}),
            ),
          );

    if (isLocalUrl) {
      loadHtmlFromAssets();
    } else {
      webViewController.loadRequest(Uri.parse(url));
    }
    ;
  }

  loadHtmlFromAssets() async {
    String fileText = await DefaultAssetBundle.of(
      Get.context!,
    ).loadString(url); //'assets/html/test.html'
    webViewController.loadHtmlString(fileText);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // webViewController?.clearCache();
    EasyLoading.dismiss();
    super.onClose();
  }
}
