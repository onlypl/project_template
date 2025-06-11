import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    bool? showError,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.get,
      url,
      params,
      loadingText: loadingText,
      showError: showError,
      success: success,
      fail: fail,
    );
  }

  /// post 请求
  static void post<T>(
    String url,
    params, {
    String? loadingText,
    bool? showError,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.post,
      url,
      params,
      loadingText: loadingText,
      showError: showError,
      success: success,
      fail: fail,
    );
  }

  /// delete 请求
  static void delete<T>(
    String url,
    params, {
    String? loadingText,
    bool? showError,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.delete,
      url,
      params,
      loadingText: loadingText,
      showError: showError,
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
    bool? showError,
    Success? success,
    Fail? fail,
  }) {
    // 参数处理（如果需要加密等统一参数）
    if (!kReleaseMode && isOpenLog) {
      Log().info('---------- HttpUtils URL ----------');
      Log().info(APIs.baseUrl + url);
      final headers = DioAdapter.instance.dio.options.headers;
      Log().info('---------- HttpUtils headers ----------');
      Log().info(headers);
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
        if ((int.tryParse(resultMap[CODE_NAME].toString()) ?? -1) ==
            ExceptionHandler.success) {
          success?.call(resultMap[DATA_NAME]);
        } else {
          ///未登录错误
          if ((int.tryParse(resultMap[CODE_NAME].toString()) ?? -1) ==
              ExceptionHandler.cookie_expired) {
            //TODO  AppHive.shared.isLogin = false;
          }
          // 其他状态，弹出错误提示信息
          if (showError ?? true) {
            ProgressHUD.showText(resultMap[MSG_NAME]);
          }
          fail?.call(
            int.tryParse(resultMap[CODE_NAME].toString()) ?? -1,
            resultMap[MSG_NAME],
          );
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
