import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project_template/app/config/translations/strings_enum.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';
import 'package:project_template/app/services/open_install_service.dart';
import 'package:project_template/app/utils/log.dart';
import 'package:project_template/app/widgets/skip_down_time_progress.dart';

import '../config/app_colors.dart';
import '../config/app_text_style.dart';
import '../routes/app_pages.dart';

///启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String netImgUrl = '';
  String tagUrl = '';
  bool _hasNavigated = false;
  bool _showDomainError = false;
  int _failureCount = 0;
  static const int _maxDomainRetryRounds = 2;

  final Dio.Dio dio = Dio.Dio(
    Dio.BaseOptions(
      responseType: Dio.ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  void initState() {
    super.initState();
    getLocalDomain();
  }

  getLocalDomain() {
    List<String> linkList = [
      "https://ox4utkt.vip",
    ];
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
    for (var tmpUrl in linkList) {
      if (domainUrlList.contains(tmpUrl) == false) {
        domainUrlList.add(tmpUrl);
      }
    }
    var currentUrl = AppSharedPreferences.getCurrentDomain();
    if (currentUrl == null || currentUrl.isEmpty) {
      if (domainUrlList.isNotEmpty) {
        AppSharedPreferences.setCurrentDomain(domainUrlList[0]);
      }
    }
    AppSharedPreferences.setDomainPool(domainUrlList);
    checkDomainAvailable(true);
  }

  ///网络获取接口域名列表
  void getDomains() {
    dio
        .get(
          'https://raw.githubusercontent.com/Luke-filbetph/domain/refs/heads/main/template.json',
        )
        .then(
          (response) {
            var resultMap =
                response.data is String
                    ? jsonDecode(response.data) as Map<String, dynamic>
                    : response.data as Map<String, dynamic>;
            List<String> linkList = List<String>.from(resultMap["links"] ?? []);
            var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
            for (var tmpUrl in linkList) {
              if (domainUrlList.contains(tmpUrl) == false) {
                domainUrlList.add(tmpUrl);
              }
            }

            var currentUrl = AppSharedPreferences.getCurrentDomain();
            if (currentUrl == null || currentUrl.isEmpty) {
              if (domainUrlList.isNotEmpty) {
                AppSharedPreferences.setCurrentDomain(domainUrlList[0]);
              }
            }
            AppSharedPreferences.setDomainPool(domainUrlList);
            _failureCount = 0;
            checkDomainAvailable(true);
          },
          onError: (error, stackTrace) {
            Log().error("域名池请求异常-----$error");
            _onDomainFailed(fetchRemoteOnExhausted: false);
          },
        );
  }

  ///url检测是否可用
  checkDomainAvailable(bool isSuccess) {
    var currentUrl = AppSharedPreferences.getCurrentDomain();
    if (currentUrl == null || currentUrl.isEmpty) {
      getDomains();
      return;
    }
    final stopwatch = Stopwatch()..start();
    dio
        .get(currentUrl)
        .then(
          (response) {
            stopwatch.stop();
            if (response.statusCode == 200) {
              Log().info("$currentUrl------域名可用------");
              goIndexPage();
            } else {
              Log().error("$currentUrl------域名不可用，状态码: ${response.statusCode}");
              _onDomainFailed();
            }
          },
          onError: (error, stackTrace) {
            Log().error("url检测是否可用请求异常-----$error");
            stopwatch.stop();
            _onDomainFailed();
          },
        );
  }

  void _onDomainFailed({bool fetchRemoteOnExhausted = true}) {
    _failureCount++;
    final poolSize = (AppSharedPreferences.getDomainPool() ?? []).length;
    if (poolSize > 0 && _failureCount >= poolSize * _maxDomainRetryRounds) {
      if (fetchRemoteOnExhausted) {
        _failureCount = 0;
        getDomains();
        return;
      }
      _showDomainErrorUI();
      return;
    }
    sortDomainArray();
    reCheckDomainAvailable(false);
  }

  void _showDomainErrorUI() {
    if (!mounted) return;
    setState(() {
      _showDomainError = true;
    });
  }

  void _retryDomainCheck() {
    setState(() {
      _showDomainError = false;
      _failureCount = 0;
      _hasNavigated = false;
    });
    getDomains();
  }

  ///排序域名池
  sortDomainArray() {
    var currentUrl = AppSharedPreferences.getCurrentDomain();
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];

    if ((currentUrl == null || currentUrl.isEmpty) && domainUrlList.isEmpty) {
      return;
    }
    for (var i = 0; i < domainUrlList.length; i++) {
      if (currentUrl == domainUrlList[i]) {
        domainUrlList.removeAt(i);
        domainUrlList.add(currentUrl!);
        break;
      }
    }
    AppSharedPreferences.setDomainPool(domainUrlList);
  }

  ///重新检测
  reCheckDomainAvailable(bool isSuccess) {
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
    if (domainUrlList.isNotEmpty) {
      AppSharedPreferences.setCurrentDomain(domainUrlList.first);
      if (domainUrlList.length > 30) {
        domainUrlList.removeLast();
      }
      AppSharedPreferences.setDomainPool(domainUrlList);
      checkDomainAvailable(isSuccess);
    } else {
      getLocalDomain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.white,
            alignment: Alignment.center,
            child:
                netImgUrl.isNotEmpty
                    ? Image.network(netImgUrl, fit: BoxFit.fill)
                    : Image.asset(
                      "assets/icon/splash_icon.png",
                      width: 160.w,
                      height: 160.w,
                      fit: BoxFit.contain,
                    ),
          ),
          if (_showDomainError)
            _buildDomainError()
          // else
          //   Positioned(
          //     left: 0,
          //     right: 0,
          //     bottom: Get.mediaQuery.padding.bottom + 100.h,
          //     child: Container(
          //       alignment: Alignment.center,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Text(
          //             Strings.findingBestRoute.tr,
          //             style: textMain14_700,
          //           ),
          //           SizedBox(width: 10.w),
          //           LoadingAnimationWidget.staggeredDotsWave(
          //             size: 30.w,
          //             color: Colors.white,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildDomainError() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48.w, color: AppColor.white),
          SizedBox(height: 16.h),
          Text(
            Strings.domainUnavailable.tr,
            style: textWhiteWith75_14_700.copyWith(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _retryDomainCheck,
            child: Text(Strings.retry.tr),
          ),
        ],
      ),
    );
  }

  ///网络广告图片
  _buildSplashBg() {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.white,
      child: CachedNetworkImage(
        placeholder:
            (context, url) => Image.asset(
              "assets/images/splash.png",
              fit: BoxFit.fill,
            ),
        imageUrl:
            netImgUrl.isNotEmpty
                ? netImgUrl
                : 'https://s2.loli.net/2024/09/24/hdEtiwT2WVGl5fo.png',
        fit: BoxFit.cover,
        errorWidget:
            (context, url, error) =>
                Image.asset("assets/images/splash.png", fit: BoxFit.fill),
      ),
    );
  }

  _buildCountdown() {
    return Visibility(
      visible: netImgUrl.isNotEmpty,
      child: Positioned(
        top: ScreenUtil().statusBarHeight + 20.h,
        right: 30,
        child: SkipDownTimeProgress(
          color: Colors.red,
          radius: 22.0,
          duration: const Duration(seconds: 5),
          size: const Size(25.0, 25.0),
          skipText: "跳过",
          onTap: () => goIndexPage(),
          onFinishCallBack: (bool value) {
            if (value) goIndexPage();
          },
        ),
      ),
    );
  }

  void goIndexPage() {
    if (_hasNavigated) return;

    final url = (AppSharedPreferences.getCurrentDomain() ?? '').trim();
    if (url.isEmpty) {
      _showDomainErrorUI();
      return;
    }

    _hasNavigated = true;
    final webUrl = OpenInstallService.appendParamsToUrl(url);
    Get.offNamed(
      Routes.BASE_WEB,
      arguments: {
        'title': '',
        'url': webUrl,
        'isShowAppBar': false,
      },
    );
  }
}
