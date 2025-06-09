import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart' as Dio;

import '../db/app_shared_preferences.dart';
import '../utils/log.dart';

class DoMainManager {
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
  final VoidCallback? jumpToPageCallback;
  DoMainManager(this.jumpToPageCallback);

  ///网络获取接口域名列表
  void getDomains() async {
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
                if (jumpToPageCallback != null) {
                  jumpToPageCallback?.call();
                }
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
                  if (jumpToPageCallback != null) {
                    jumpToPageCallback?.call();
                  }
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
}
