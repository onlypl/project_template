import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../db/app_hive.dart';
import '../utils/log.dart';
import '../utils/progress_hud.dart';
import 'apis.dart';
import 'dio_adapter.dart';
import 'intercept.dart';
import 'net_error.dart';

typedef Success<T> = Function(T data);
typedef Fail = Function(int code, String msg);

// 日志开关
const bool isOpenLog = true;
const bool isOpenAllLog = false;

//参数名称
const String CODE_NAME = "code";
const String MSG_NAME = "msg";
const String DATA_NAME = "data";
const String LIST_NAME = "list";

class HttpUtils {
  ///dio main函数初始化
  static void initDio() {
    final List<Interceptor> interceptors = <Interceptor>[];

    /// 统一添加身份验证请求头
    //interceptors.add(AuthInterceptor());

    /// 刷新Token
    interceptors.add(TokenInterceptor());

    ///刷新登录
    interceptors.add(LoginInterceptor());

    /// 打印Log(生产模式去除)
    if (!kReleaseMode && isOpenAllLog) {
      interceptors.add(LoggingInterceptor()); // 调试打开
    }

    configDio(baseUrl: APIs.baseUrl, interceptors: interceptors);
  }

  static setBaseUrl(String baseUrl) {
    DioAdapter.instance.dio.options.baseUrl = baseUrl;
  }

  /// get 请求
  static void get<T>(
    String url,
    Map<String, dynamic>? params, {
    String? loadingText,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.get,
      url,
      params,
      loadingText: loadingText,
      success: success,
      fail: fail,
    );
  }

  /// post 请求
  static void post<T>(
    String url,
    params, {
    String? loadingText,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.post,
      url,
      params,
      loadingText: loadingText,
      success: success,
      fail: fail,
    );
  }

  /// delete 请求
  static void delete<T>(
    String url,
    params, {
    String? loadingText,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.delete,
      url,
      params,
      loadingText: loadingText,
      success: success,
      fail: fail,
    );
  }

  /// _request 请求
  static void request<T>(
    Method method,
    String url,
    params, {
    String? loadingText,
    Success? success,
    Fail? fail,
  }) {
    // 参数处理（如果需要加密等统一参数）
    if (!kReleaseMode && isOpenLog) {
      Log().info('---------- HttpUtils URL ----------');
      Log().info(url);
      Log().info('---------- HttpUtils params ----------');
      Log().info(params);
    }

    Object? data;
    Map<String, dynamic>? queryParameters;
    if (method == Method.get) {
      queryParameters = params;
    }
    if (method == Method.post) {
      data = params;
    }
    if (method == Method.delete) {
      data = params;
    }
    if (loadingText != null) {
      ProgressHUD.showLoadingText(loadingText);
    }
    DioAdapter.instance.request(
      method,
      url,
      data: data,
      queryParameters: queryParameters,
      onSuccess: (result) {
        var resultMap = result is String ? jsonDecode(result) : result;
        if (!kReleaseMode && isOpenLog) {
          Log().debug('---------- HttpUtils response ----------');
          Log().debug('!!!!!!$resultMap');
        }
        if (loadingText != null) {
          ProgressHUD.hide();
        }
        if (resultMap[CODE_NAME] == ExceptionHandler.success) {
          success?.call(resultMap);
        } else {
          ///未登录错误
          if (resultMap[CODE_NAME] == ExceptionHandler.cookie_expired) {
            AppHive.shared.isLogin = false;
          }
          // 其他状态，弹出错误提示信息
          ProgressHUD.showText(resultMap[MSG_NAME]);
          fail?.call(resultMap[CODE_NAME], resultMap[MSG_NAME]);
        }
      },
      onError: (code, msg) {
        Log().error('---------- $msg ----------');
        if (loadingText != null) {
          ProgressHUD.hide();
        }
        ProgressHUD.showError(msg);
        fail?.call(code, msg);
      },
    );
  }
}
