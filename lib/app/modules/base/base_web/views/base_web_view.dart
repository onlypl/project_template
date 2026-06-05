import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/translations/strings_enum.dart';
import 'package:project_template/app/widgets/base_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/base_web_controller.dart';

class BaseWebView extends GetView<BaseWebController> {
  const BaseWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        extendBodyBehindAppBar: controller.isShowAppBar,
        appBar:
            controller.isShowAppBar
                ? BaseAppBar(
                  title: controller.title,
                  leftItemCallBack: controller.handleAppBarBack,
                )
                : null,
        body: SafeArea(
        //  top:  false,
         top:  !controller.isShowAppBar,
          bottom: false,
          left: false,
          right: false,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await controller.handleSystemBack();
              if (shouldPop && context.mounted) {
                SystemNavigator.pop();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildAppWebView(context),
                _buildProgressBar(),
                _buildErrorOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppWebView(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    controller.updateSafeAreaInsets(
      top: controller.isShowAppBar ? 0 : viewPadding.top,
      bottom: viewPadding.bottom,
    );

    return InAppWebView(
      key: controller.webViewKey,
      initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(controller.url))),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccess: true,
        allowContentAccess: true,
        allowsInlineMediaPlayback: true,
        useShouldOverrideUrlLoading: true,
        useOnLoadResource: true,
        useOnDownloadStart: true,
        useHybridComposition: true,
        allowsBackForwardNavigationGestures: true,
        javaScriptCanOpenWindowsAutomatically: true,
        thirdPartyCookiesEnabled: true,
        supportMultipleWindows: true,
        userAgent: controller.userAgent,
      ),
      onWebViewCreated: controller.setupWebView,
      onLoadStart: (cont, url) => controller.onLoadStart(),
      onLoadStop: (cont, url) => controller.onLoadStop(url),
      onProgressChanged: (cont, progress) => controller.onProgress(progress),
      onReceivedError: (cont, request, error) {
        controller.onReceivedError(request.url, error.description);
      },
      onTitleChanged: (cont, title) {
        if (title != null && title.isNotEmpty) {
          controller.pageTitle.value = title;
        }
      },
      onCreateWindow: (cont, action) async {
        final uri = action.request.url;
        if (uri == null) return false;
        await controller.inWebViewController.loadUrl(
          urlRequest: URLRequest(url: uri),
        );
        return true;
      },
      shouldOverrideUrlLoading: (cont, action) async {
        final uri = action.request.url;
        if (uri == null) return NavigationActionPolicy.ALLOW;
        final scheme = uri.scheme;
        if (scheme == 'http' || scheme == 'https') {
          return NavigationActionPolicy.ALLOW;
        }
        await _openExternal(uri);
        return NavigationActionPolicy.CANCEL;
      },
      onPermissionRequest: (cont, request) async {
        return controller.handlePermissionRequest(request);
      },
      onGeolocationPermissionsShowPrompt: (cont, origin) async {
        return controller.handleGeolocationPermission(origin);
      },
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      if (!controller.isLoading.value || controller.loadProgress.value >= 100) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: LinearProgressIndicator(
          value: controller.loadProgress.value / 100,
          minHeight: 2.h,
          backgroundColor: Colors.transparent,
        ),
      );
    });
  }

  Widget _buildErrorOverlay() {
    return Obx(() {
      if (!controller.hasError.value) return const SizedBox.shrink();
      return Container(
        color: Get.theme.scaffoldBackgroundColor,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.w,
              color: Get.theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              Strings.pageLoadFailed.tr,
              style: Get.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.reload,
              child: Text(Strings.retry.tr),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _openExternal(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
