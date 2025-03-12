import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../utils/cookie_handle.dart';
import '../utils/log.dart';
import 'apis.dart';
import 'net_error.dart';

//默认dio配置
String _baseUrl = APIs.baseUrl;
Duration _connectTimeout = const Duration(seconds: 30); //连接超时时间
Duration _receiveTimeout = const Duration(seconds: 30); //接收超时时间
//Duration _sendTimeout = const Duration(seconds: 15); //发送超时时间
List<Interceptor> _interceptors = []; //拦截器数组

typedef NetSuccessCallback<T> = Function(T data); //成功回调 普通类型
typedef NetSuccessListCallback<T> = Function(List<T> data); //成功回调 数组类型
typedef NetErrorCallback = Function(int code, String msg); //错误回调

/// 初始化Dio配置
void configDio({
  Duration? connectTimeout,
  Duration? receiveTimeout,
  Duration? sendTimeout,
  String? baseUrl,
  List<Interceptor>? interceptors,
}) {
  _connectTimeout = connectTimeout ?? _connectTimeout;
  _receiveTimeout = receiveTimeout ?? _receiveTimeout;
  // _sendTimeout = sendTimeout ?? _sendTimeout;
  _baseUrl = baseUrl ?? _baseUrl;
  _interceptors = interceptors ?? _interceptors;
}

class DioAdapter {
  // 工厂模式 : 单例公开访问点
  factory DioAdapter() => _singleton;
  static final DioAdapter _singleton = DioAdapter._();
  static DioAdapter get instance => DioAdapter();

  static late Dio _dio;
  Dio get dio => _dio;
  DioAdapter._() {
    // 全局属性：请求前缀、连接超时时间、响应超时时间
    final BaseOptions options = BaseOptions(
      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 “Headers.formUrlEncodedContentType”,  这样[Dio]就会自动编码请求体.
      /// contentType: Headers.formUrlEncodedContentType, // 适用于post form表单提交
      responseType: ResponseType.json,
      validateStatus: (status) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },

      baseUrl: _baseUrl,
      headers: _httpHeaders,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      //sendTimeout: _sendTimeout,
    );
    _dio = Dio(options);

    /// Fiddler抓包代理配置
    // dio.httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.findProxy = (uri) {
    //       // 将请求代理至 localhost:8888。
    //       // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
    //       return 'PROXY localhost:8888';
    //     };
    //     // 抓Https包设置
    //     client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   },
    // );
    // 测试环境忽略证书校验
    var isTest = !kReleaseMode || APIs.baseUrl.startsWith('https://192');
    // Log().info('!!!!!!!!!!!---${ScreenUtil().deviceType(context)}');
    // if (isTest && ScreenUtil().deviceType() == DeviceType.mobile) {
    if (isTest) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    ///拦截器
    void addInterceptor(Interceptor interceptor) {
      _dio.interceptors.add(interceptor);
    }

    _interceptors.forEach(addInterceptor);
  }

  Future request<T>(
    Method method,
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    NetSuccessCallback? onSuccess,
    NetErrorCallback? onError,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      //  没有网络 调用错误异常回调
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult.contains(ConnectivityResult.none)) {
      //   _onError(ExceptionHandler.net_error, '网络异常，请检查你的网络！', onError);
      //   return;
      // }

      final Response response = await _dio.request<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(_methodValues[method], options),
        cancelToken: cancelToken,
      );
      if (APIs.login == url) {
        CookieHandle.saveCookie(url);
      }

      /// 获取Cookie，CookieManager 为插件cookie管理类，CookieHandle.cookieJar 是获取Cookie
      dio.interceptors.add(CookieManager(await CookieHandle.cookieJar));
      onSuccess?.call(response.data);
    } on DioException catch (e) {
      _cancelLogPrint(e, url);
      Log().error('错误 $e');
      final NetError error = ExceptionHandler.handlerException(e);
      _onError(error.code, error.msg, onError);
    }
  }
}

//检测全局属性类
Options _checkOptions(String? method, Options? options) {
  options ??= Options();
  options.method = method;
  return options;
}

//取消请求日志打印
void _cancelLogPrint(dynamic e, String url) {
  if (e is DioException && CancelToken.isCancel(e)) {
    Log().error('取消请求接口： $url');
  }
}

///code异常处理和回调
void _onError(int? code, String msg, NetErrorCallback? onError) {
  if (code == null) {
    code = ExceptionHandler.unknown_error;
    msg = '未知异常';
  }
  Log().error('接口请求异常： code: $code, mag: $msg');
  onError?.call(code, msg);
}

/// 自定义Header
Map<String, dynamic> _httpHeaders = {
  //  'Accept': 'application/json,*/*',
  'Content-Type': 'application/json',
};

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

enum Method { get, post, put, patch, delete, head }

/// 使用：_methodValues[Method.post]
const _methodValues = {
  Method.get: 'get',
  Method.post: 'post',
  Method.delete: 'delete',
  Method.put: 'put',
  Method.patch: 'patch',
  Method.head: 'head',
};
