import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_template/app/http/apis.dart';
import 'package:project_template/app/utils/log.dart';

class BaseWebController extends GetxController {
  late String title = '';
  late String url = '';
  late String richText = '';
  late bool isLocalUrl = false;
  late bool isShowAppBar = false;

  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController inWebViewController;

  final isLoading = true.obs;
  final hasError = false.obs;
  final loadProgress = 0.obs;
  final pageTitle = ''.obs;

  double safeAreaTop = 0;
  double safeAreaBottom = 0;

  void updateSafeAreaInsets({required double top, required double bottom}) {
    safeAreaTop = top;
    safeAreaBottom = bottom;
  }

  String get userAgent {
    final os = Platform.operatingSystem;
    return 'CaiDaApp/1.0.0 (Flutter; $os)';
  }

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments;
    final argUrl = (args?['url'] as String?)?.trim();
    url =
        (argUrl != null && argUrl.isNotEmpty) ? argUrl : APIs.baseUrl;
    title = args?['title'] ?? '';
    richText = args?['richText'] ?? '';
    isLocalUrl = args?['isLocalUrl'] ?? false;
    isShowAppBar = args?['isShowAppBar'] ?? false;
  }

  Future<void> setupWebView(InAppWebViewController controller) async {
    inWebViewController = controller;

    controller.addJavaScriptHandler(
      handlerName: 'FlutterBridge',
      callback: (args) {
        Log().info('H5 -> Native: $args');
        if (args.isEmpty) return {'status': 'ok'};
        final data = args.first;
        if (data is Map && data['action'] == 'getAppInfo') {
          return {
            'platform': Platform.operatingSystem,
            'userAgent': userAgent,
            'version': '1.0.0',
            'safeAreaInsets': {
              'top': safeAreaTop,
              'bottom': safeAreaBottom,
            },
          };
        }
        if (data is Map && data['action'] == 'requestPermission') {
          return requestPermissionByName(data['permission'] as String?);
        }
        return {'status': 'ok'};
      },
    );
  }

  Future<void> injectBridgeScript() async {
    final top = safeAreaTop;
    final bottom = safeAreaBottom;
    await inWebViewController.evaluateJavascript(source: '''
      (function() {
        var top = $top;
        var bottom = $bottom;
        document.documentElement.style.setProperty('--app-safe-area-top', top + 'px');
        document.documentElement.style.setProperty('--app-safe-area-bottom', bottom + 'px');

        if (!window.FlutterBridge) {
          window.FlutterBridge = {
            postMessage: function(data) {
              return window.flutter_inappwebview.callHandler('FlutterBridge', data);
            },
            getAppInfo: function() {
              return window.flutter_inappwebview.callHandler('FlutterBridge', {action: 'getAppInfo'});
            },
            requestPermission: function(permission) {
              return window.flutter_inappwebview.callHandler('FlutterBridge', {action: 'requestPermission', permission: permission});
            }
          };
        }
      })();
    ''');
  }

  void onLoadStart() {
    isLoading.value = true;
    hasError.value = false;
    loadProgress.value = 0;
  }

  void onLoadStop(WebUri? loadedUrl) {
    isLoading.value = false;
    loadProgress.value = 100;
    injectBridgeScript();
  }

  void onProgress(int progress) {
    loadProgress.value = progress;
    if (progress >= 100) {
      isLoading.value = false;
    }
  }

  void onReceivedError(WebUri? failedUrl, String description) {
    isLoading.value = false;
    hasError.value = true;
    Log().error('WebView load error: $failedUrl - $description');
  }

  Future<void> reload() async {
    hasError.value = false;
    isLoading.value = true;
    loadProgress.value = 0;
    await inWebViewController.reload();
  }

  /// 系统返回键：优先 WebView 历史后退，无历史则退出应用。
  Future<bool> handleSystemBack() async {
    if (await inWebViewController.canGoBack()) {
      await inWebViewController.goBack();
      return false;
    }
    return true;
  }

  /// AppBar 返回按钮
  Future<void> handleAppBarBack() async {
    if (await inWebViewController.canGoBack()) {
      await inWebViewController.goBack();
    } else {
      SystemNavigator.pop();
    }
  }

  /// H5 通过 JS Bridge 主动申请系统权限（camera / microphone / photos / location）
  Future<Map<String, dynamic>> requestPermissionByName(String? name) async {
    final permission = _mapPermissionName(name);
    if (permission == null) {
      return {'granted': false, 'error': 'unsupported_permission'};
    }
    final status = await permission.request();
    return {
      'granted': status.isGranted,
      'status': status.name,
      'permission': name,
    };
  }

  Permission? _mapPermissionName(String? name) {
    switch (name) {
      case 'camera':
        return Permission.camera;
      case 'microphone':
        return Permission.microphone;
      case 'photos':
        return Permission.photos;
      case 'location':
        return Permission.locationWhenInUse;
      default:
        return null;
    }
  }

  /// WebView 内 H5 调用 getUserMedia 等 API 时触发，此时才向系统申请权限。
  Future<PermissionResponse> handlePermissionRequest(
    PermissionRequest request,
  ) async {
    var granted = true;
    for (final resource in request.resources) {
      if (resource == PermissionResourceType.CAMERA) {
        if (!(await Permission.camera.request()).isGranted) {
          granted = false;
        }
      } else if (resource == PermissionResourceType.MICROPHONE) {
        if (!(await Permission.microphone.request()).isGranted) {
          granted = false;
        }
      }
    }
    return PermissionResponse(
      resources: request.resources,
      action:
          granted
              ? PermissionResponseAction.GRANT
              : PermissionResponseAction.DENY,
    );
  }

  Future<GeolocationPermissionShowPromptResponse?>
  handleGeolocationPermission(String origin) async {
    final status = await Permission.locationWhenInUse.request();
    return GeolocationPermissionShowPromptResponse(
      origin: origin,
      allow: status.isGranted,
      retain: status.isGranted,
    );
  }

  @override
  void onClose() {
    EasyLoading.dismiss();
    super.onClose();
  }
}
