import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';
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
  //final HomeController controller = Get.put(HomeController());
  String netImgUrl = '';
  String tagUrl = '';
  // String netImgUrlPlaceholder = 'https://hbimg.b0.upaiyun.com/bb7e3b7ba10a607e0efd72b23087fa5415ca3cd040cc-7Ncw9V_fw236';//一个loading的图片
  final Dio.Dio dio = Dio.Dio(
    Dio.BaseOptions(
      responseType: Dio.ResponseType.json,
      // validateStatus: (status) {
      //   // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
      //   return true;
      // },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      //sendTimeout: _sendTimeout,
    ),
  );
  @override
  void initState() {
    super.initState();
    getDomains();
    // getAPPConfig();
    // getCategoryList();
    //  getData();
  }

  ///网络获取接口域名列表
  void getDomains() {
    dio
        .get(
          'https://raw.githubusercontent.com/Luke-filbetph/domain/refs/heads/main/template.json',
        )
        .then(
          (response) {
            print(response.data);
            var resultMap =
                response.data is String
                    ? jsonDecode(response.data) as Map<String, dynamic>
                    : response.data as Map<String, dynamic>;
            List<String> linkList = List<String>.from(resultMap["links"] ?? []);
            //获取缓存的域名池
            var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
            for (var tmpUrl in linkList) {
              //如果当前缓存域名池没有接口域名池的域名时 则添加到缓存数组中
              if (domainUrlList.contains(tmpUrl) == false) {
                domainUrlList.add(tmpUrl);
              }
            }

            //看是否当前域名是否存在 不存在则初始化添加
            var currentUrl = AppSharedPreferences.getCurrentDomain();
            if (currentUrl == null || currentUrl.isEmpty) {
              //如果当前域名不存在 则初始化添加
              if (domainUrlList.isNotEmpty) {
                AppSharedPreferences.setCurrentDomain(domainUrlList[0]);
              }
            }
            //更新缓存的域名池
            AppSharedPreferences.setDomainPool(domainUrlList);
            checkDomainAvailable(true);
          },
          onError: (error, stackTrace) {
            Log().error("域名池请求异常-----$error");
          },
        );
  }

  ///url检测是否可用
  checkDomainAvailable(bool isSuccess) {
    var currentUrl = AppSharedPreferences.getCurrentDomain();
    if (currentUrl == null || currentUrl.isEmpty) {
      getDomains(); //重新请求接口域名池
      return;
    }
    final stopwatch = Stopwatch()..start();
    try {
      dio
          .get(currentUrl)
          .then(
            (response) {
              stopwatch.stop();
              if (response.statusCode == 200) {
                print('请求成功，耗时: ${stopwatch.elapsedMilliseconds} 毫秒');
                Log().info("$currentUrl------域名可用------");

                ///请求处理请求配置接口或者其它数据/跳转页面等操作
                goIndexPage();
              }
            },
            onError: (error, stackTrace) {
              Log().error("url检测是否可用请求异常-----$error");
              stopwatch.stop();
              sortDomainArray(); //排序域名池,访问失败的url排在最后
              reCheckDomainAvailable(false); //新的域名下载备用域名列表
            },
          );
    } catch (e) {
      stopwatch.stop();
      Log().error("url检测是否可用捕获到异常-----$e");
    }
  }

  ///排序域名池
  sortDomainArray() {
    var currentUrl = AppSharedPreferences.getCurrentDomain();
    //获取缓存的域名池
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];

    if ((currentUrl == null || currentUrl.isEmpty) && domainUrlList.isEmpty) {
      return;
    }
    for (var i = 0; i < domainUrlList.length; i++) {
      if (currentUrl == domainUrlList[i]) {
        //移除域名添加到末尾
        domainUrlList.removeAt(i);
        domainUrlList.add(currentUrl!);
        break;
      }
    }
    //更新缓存的域名池
    AppSharedPreferences.setDomainPool(domainUrlList);
  }

  ///重新检测
  reCheckDomainAvailable(bool isSuccess) {
    //获取缓存的域名池
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
    if (domainUrlList.isNotEmpty) {
      //更新当前域名 设置为第一个
      AppSharedPreferences.setCurrentDomain(domainUrlList.first);
      //大于30个域名时 移除掉最后一个
      if (domainUrlList.length > 30) {
        domainUrlList.removeLast();
      }
      AppSharedPreferences.setDomainPool(domainUrlList);
      checkDomainAvailable(isSuccess);
    } else {
      getDomains(); //重新请求接口域名池
    }
  }

  ///一次性请求多个接口
  requestMultipleInterfaces() {
    //获取缓存的域名池
    var domainUrlList = AppSharedPreferences.getDomainPool() ?? [];
    // 存储每个请求的CancelToken
    List<Dio.CancelToken> cancelTokens = List.generate(
      domainUrlList.length,
      (_) => Dio.CancelToken(),
    );
    // 存储每个请求的Future
    List<Future<Dio.Response>> futures = [];
    // 并发请求所有URLs
    for (int i = 0; i < domainUrlList.length; i++) {
      futures.add(
        dio
            .get(domainUrlList[i], cancelToken: cancelTokens[i])
            .then((response) {
              // 检查状态码是否为200，如果是，则取消其他请求
              if (response.statusCode == 200) {
                for (int j = 0; j < cancelTokens.length; j++) {
                  if (j != i) {
                    cancelTokens[j].cancel("Request already successful");
                  }
                  ///请求处理请求配置接口或者其它数据/跳转页面等操作
                  goIndexPage();
                }
              }
              return response; // 返回响应以便后续处理
            })
            .catchError((error) {
              // 处理错误情况，例如打印日志或进行其他操作
              Log().error('Error fetching data: $error');
            }),
      );
    }

    // 等待所有请求完成（无论成功或失败）
    try {
      Future.wait(futures).then((responseList) {
        Log().info('所有请求完成（无论成功或失败）');
        //可以获取到请求列表
        Log().info('responseList: $responseList');
      });
    } catch (e) {
      Log().error('An error occurred: $e');
    } finally {
      // 清理资源：取消所有剩余的请求（理论上这一步在上面的循环中已经完成）
      cancelTokens.forEach((token) => token.cancel());
    }
  }

  // getData(){
  //   //模拟广告图接口请求
  //   HttpUtils.get(
  //     APIs.startUp,
  //     {},
  //     success: (result) {
  //       var model = ConfigModel.fromJson(result[DATA_NAME]);
  //       netImgUrl = model.ads?.startupAdv?.imgUrl ?? '';
  //       tagUrl = model.ads?.startupAdv?.targetUrl ?? '';
  //       var resultMap = result[DATA_NAME];
  //       AppSharedPreferences.setStorage(AppConstants.appConfig, resultMap);
  //       if (netImgUrl.isNotEmpty) {
  //         /**刷新页面使广告图显示**/
  //         setState(() {});
  //         //无广告页：netImgUrl为空""
  //       } else {
  //         /**跳转到主页**/
  //         Future.delayed(const Duration(microseconds: 10), goIndexPage);
  //       }
  //     },
  //     fail: (int code, String msg) {},
  //   );
  //   Future.delayed(const Duration(microseconds: 1000), () {
  //     //   netImgUrl =
  //     //     'https://img2.baidu.com/it/u=1170834292,3580907519&fm=253&fmt=auto&app=138&f=JPG?w=500&h=889';
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          //普通写法
          Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.white,
            child:
                netImgUrl.isNotEmpty
                    ? Image.network(netImgUrl, fit: BoxFit.fill)
                    : Image.asset(
                      "assets/images/splash.png",
                      fit: BoxFit.fill,
                    ), //未请求回来之前，用启动页图片作为占位图
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Get.mediaQuery.padding.bottom + 100.h,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('正在寻找最佳线路'.tr, style: textWhiteWith75_14_700),
                  SizedBox(width: 10.w),
                  LoadingAnimationWidget.staggeredDotsWave(
                    size: 30.w,
                    color: AppColor.white,
                  ),
                ],
              ),
            ),
          ),

          // // 使用 CachedNetworkImage
          // _buildSplashBg(),
          // //倒计时：跳过
          // _buildCountdown(),
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
            ), ////未请求回来之前，用启动页图片作为占位图
        imageUrl:
            netImgUrl.isNotEmpty
                ? netImgUrl
                : 'https://s2.loli.net/2024/09/24/hdEtiwT2WVGl5fo.png', //在netImgUrl请求回来之前占位url，防止CachedNetworkImage加载空url报错
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

  // 跳转主页
  void goIndexPage() {
    print('进入了主页......');

    Get.offNamed(Routes.TABS);

    ///   Navigator.of(context).pushReplacementNamed(Routes.TABS);
  }

  ///获取APP配置
  // void getAPPConfig() async {
  //   HttpUtils.get(APIs.startUp, {}, success: (result) {
  //     //var model = ConfigModel.fromJson(result[DATA_NAME]);
  //     // AppBox.shared.configInfo = model;
  //     var resultMap = result[DATA_NAME];
  //     var ps = Storage();
  //     ps.setStorage(TvConstants.appConfig, resultMap);
  //   }, fail: (int code, String msg) {});
  // }

  ///获取首页分类
  // void getCategoryList() async {
  //   HttpUtils.get(APIs.types, {}, success: (result) {
  //     var categoryMap = result[DATA_NAME];
  //     var list = categoryMap[LIST_NAME];
  //     // var ps = Storage();
  //     // ps.setStorage(TvConstants.categoryList, list);
  //     controller.updateCategory(list);
  //   }, fail: (int code, String msg) {});
  // }
}
