import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/log.dart';
import '../utils/progress_hud.dart';
import 'apis.dart';
import 'dio_adapter.dart';
import 'intercept.dart';
import 'net_error.dart';

enum FailType {
  interface(1, '接口异常'), // 1 - 接口异常
  data(2, '数据异常'), // 2 -  数据异常
  network(3, '网络请求异常'); //3 - 网络请求异常

  final int code;
  final String desc;

  const FailType(this.code, this.desc);
  static FailType? fromCode(int code) {
    return FailType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => FailType.network,
    );
  }
}

typedef Success<T> = Function(T data);
typedef Fail = Function(FailType failType, int code, String msg);
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
    interceptors.add(AuthInterceptor());

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
        try {
          //  if (!kReleaseMode && isOpenLog) {
          Log().debug('---------- HttpUtils response ----------');
          Log().debug('数据:$url----$result');
          //  }
          Map<String, dynamic> resultMap = {};
          if (result is String) {
            if (result.trim().isNotEmpty) {
              resultMap = jsonDecode(result);
            }
            {
              Log().debug('----------数据为空 ----------');
            }
          } else if (result is Map<String, dynamic>) {
            resultMap = result;
          } else {
            Log().debug('----------数据类型不确定 ----------');
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
                ExceptionHandler.token_expired) {
              //TODO  AppHive.shared.isLogin = false;
            }
            // 其他状态，弹出错误提示信息
            if (showError ?? true) {
              ProgressHUD.showText(resultMap[MSG_NAME]);
            }
            fail?.call(
              FailType.interface,
              int.tryParse(resultMap[CODE_NAME].toString()) ?? -1,
              resultMap[MSG_NAME],
            );
          }
        } catch (e) {
          Log().error('接口数据异常--------------$e');
          fail?.call(FailType.data, -1, '数据解析异常');
          ProgressHUD.hide();
        }
      },
      onError: (code, msg) {
        Log().error('网络请求异常---------- $msg ----------');
        if (loadingText != null) {
          ProgressHUD.hide();
        }
        fail?.call(FailType.network, code, msg);
      },
    );
  }

  /// 上传文件（通用方法）
  /// [filePath] 本地文件路径
  /// [url] 上传接口地址
  /// [fieldName] 表单字段名，默认 'file'
  /// [onSendProgress]上传进度
  /// [onReceiveProgress]下载进度
  /// [cancelToken] 可用于取消请求
  static void uploadFile(
    String url,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    String? loadingText,
    bool? showError,
    Success? success,
    Fail? fail,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    if (loadingText != null) {
      ProgressHUD.showLoadingText(loadingText);
    }

    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      if (extraData != null) ...extraData,
    });

    if (!kReleaseMode && isOpenLog) {
      Log().info('---------- 上传单个文件 ----------');
      Log().info(APIs.baseUrl + url);
      Log().info(formData.fields);
    }

    DioAdapter.instance.request(
      Method.post,
      url,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onSendProgress,
      onSuccess: (result) {
        try {
          var resultMap = result is String ? jsonDecode(result) : result;
          if ((int.tryParse(resultMap[CODE_NAME].toString()) ?? -1) ==
              ExceptionHandler.success) {
            success?.call(resultMap[DATA_NAME]);
          } else {
            if (showError ?? true) {
              ProgressHUD.showText(resultMap[MSG_NAME]);
            }
            fail?.call(
              FailType.interface,
              int.tryParse(resultMap[CODE_NAME].toString()) ?? -1,
              resultMap[MSG_NAME],
            );
          }
        } catch (e) {
          Log().error('上传文件数据异常: $e');
          fail?.call(FailType.data, -1, '数据解析异常');
          ProgressHUD.showText(e.toString());
        } finally {
          if (loadingText != null) ProgressHUD.hide();
        }
      },
      onError: (code, msg) {
        Log().error('上传文件接口异常: $msg');
        if (loadingText != null) ProgressHUD.hide();
        // ProgressHUD.showError(msg);
        fail?.call(FailType.network, code, msg);
      },
    );
  }

  /// 上传图片（封装 uploadFile，字段名默认 'image'）
  /// [imagePath] 图片路径
  /// [fieldName] 字段名默认 'image'
  /// [onSendProgress] 上传进度监听
  /// [onReceiveProgress]下载进度
  /// [cancelToken] 可用于取消请求
  static void uploadImage(
    String url,
    String imagePath, {
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    String? loadingText,
    bool? showError,
    Success? success,
    Fail? fail,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    uploadFile(
      url,
      imagePath,
      fieldName: fieldName,
      extraData: extraData,
      loadingText: loadingText,
      showError: showError,
      success: success,
      fail: fail,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// 上传多文件（支持图片）
  /// [filePaths] 文件路径列表
  /// [fieldName] 接收字段名，通常为 'files'
  /// [onSendProgress] 上传进度监听
  /// [cancelToken] 可用于取消请求
  static void uploadMultipleFiles(
    String url,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? extraData,
    String? loadingText,
    bool? showError,
    Success? success,
    Fail? fail,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    if (loadingText != null) {
      ProgressHUD.showLoadingText(loadingText);
    }

    final List<MultipartFile> files = await Future.wait(
      filePaths.map(
        (path) async =>
            await MultipartFile.fromFile(path, filename: path.split('/').last),
      ),
    );

    final formData = FormData.fromMap({
      fieldName: files,
      if (extraData != null) ...extraData,
    });

    if (!kReleaseMode && isOpenLog) {
      Log().info('---------- 上传多个文件 ----------');
      Log().info(APIs.baseUrl + url);
      Log().info(formData.fields);
    }
    DioAdapter.instance.request(
      Method.post,
      url,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onSuccess: (result) {
        try {
          var resultMap = result is String ? jsonDecode(result) : result;
          if ((int.tryParse(resultMap[CODE_NAME].toString()) ?? -1) ==
              ExceptionHandler.success) {
            success?.call(resultMap[DATA_NAME]);
          } else {
            if (showError ?? true) {
              ProgressHUD.showText(resultMap[MSG_NAME]);
            }
            fail?.call(
              FailType.interface,
              int.tryParse(resultMap[CODE_NAME].toString()) ?? -1,
              resultMap[MSG_NAME],
            );
          }
        } catch (e) {
          Log().error('上传多个文件数据异常: $e');
          fail?.call(FailType.data, -1, '数据解析异常');
          //  ProgressHUD.showText(e.toString());
        } finally {
          if (loadingText != null) ProgressHUD.hide();
        }
      },
      onError: (code, msg) {
        Log().error('上传多个文件接口异常: $msg');
        if (loadingText != null) ProgressHUD.hide();
        // ProgressHUD.showError(msg);
        fail?.call(FailType.network, code, msg);
      },
    );
  }
}
