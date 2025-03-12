import 'package:dio/dio.dart';

import '../db/app_hive.dart';
import '../db/app_shared_preferences.dart';
import '../utils/log.dart';
import 'apis.dart';
import 'dio_adapter.dart';
import 'http_utils.dart';
import 'net_error.dart';

const String kRefreshTokenUrl = APIs.refreshToken; //刷新token地址
String? getToken() {
  var token = AppSharedPreferences.getAppToken();
  return token;
}

void setToken(accessToken) {
  AppSharedPreferences.setString('accessToken', accessToken);
}

String? getRefreshToken() {
  var refreshToken = AppSharedPreferences.getAppToken();
  return refreshToken;
}

void setRefreshToken(refreshToken) {
  AppSharedPreferences.setAppToken(refreshToken);
}

/// 统一添加身份验证请求头（根据项目自行处理）
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path != APIs.login) {
      final String? accessToken = getToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    super.onRequest(options, handler);
  }
}

///过期后自动刷新Cookie
class LoginInterceptor extends QueuedInterceptor {
  Dio? _loginDio;

  Future<Map<String, dynamic>?> refreshCookieRequest() async {
    var params = {
      'user_name': AppHive.shared.userName,
      'user_pwd': AppHive.shared.password,
    };
    try {
      _loginDio ??= Dio();
      _loginDio!.options = DioAdapter.instance.dio.options;
      final Response<dynamic> response = await _loginDio!.post<dynamic>(
        APIs.login,
        data: params,
      );
      var res = response.data as dynamic;
      if (res[CODE_NAME] == ExceptionHandler.success) {
        return response.data;
      }
    } catch (e) {
      AppHive.shared.isLogin = false;
      Log().error('---------- 自动刷新Cookie失败！----------');
    }
    return null;
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // 403代表Cookie过期
    if (response.statusCode == ExceptionHandler.cookie_expired) {
      Log().debug('---------- 自动刷新Cookie ----------');

      var res = await refreshCookieRequest(); // 获取Cookie
      if (res != null) {
        Log().error('---------- 刷新Cookie后返回----------');
        // 重新请求失败接口
        final RequestOptions request = response.requestOptions;

        try {
          Log().error('---------- 重新请求接口 ----------');
          final Options options = Options(
            headers: request.headers,
            method: request.method,
          );

          /// 避免重复执行拦截器，使用loginDio
          final Response<dynamic> response = await _loginDio!.request<dynamic>(
            request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: options,
            onReceiveProgress: request.onReceiveProgress,
          );
          return handler.next(response);
        } on DioException catch (e) {
          AppHive.shared.isLogin = false;
          return handler.reject(e);
        }
      }
    }
    super.onResponse(response, handler);
  }
}

/// 刷新Token（根据项目自行处理）
class TokenInterceptor extends QueuedInterceptor {
  Dio? _tokenDio;

  Future<Map<String, dynamic>?> refreshTokenRequest() async {
    var params = {'accessToken': getToken(), 'refreshToken': getRefreshToken()};
    try {
      _tokenDio ??= Dio();
      _tokenDio!.options = DioAdapter.instance.dio.options;
      _tokenDio!.options.headers['Authorization'] = 'Bearer ${getToken()}';
      final Response<dynamic> response = await _tokenDio!.post<dynamic>(
        kRefreshTokenUrl,
        data: params,
      );
      var res = response.data as dynamic;
      if (res['code'] == ExceptionHandler.success) {
        return response.data;
      }
      // if (response.statusCode == ExceptionHandle.success) {
      //   return response.data;
      // }
    } catch (e) {
      Log().error('---------- 刷新Token失败！----------');
    }
    return null;
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // 401代表token过期
    if (response.statusCode == ExceptionHandler.unauthorized) {
      Log().debug('---------- 自动刷新Token ----------');

      var res = await refreshTokenRequest(); // 获取新的accessToken
      if (res != null) {
        var accessToken = res['accessToken'];
        Log().error('---------- NewToken: $accessToken ----------');

        // 保存token
        setToken(accessToken);
        setRefreshToken(res['refreshToken']);

        // 重新请求失败接口
        final RequestOptions request = response.requestOptions;
        request.headers['Authorization'] = 'Bearer $accessToken';

        final Options options = Options(
          headers: request.headers,
          method: request.method,
        );

        try {
          Log().error('---------- 重新请求接口 ----------');

          /// 避免重复执行拦截器，使用tokenDio
          final Response<dynamic> response = await _tokenDio!.request<dynamic>(
            request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: options,
            onReceiveProgress: request.onReceiveProgress,
          );
          return handler.next(response);
        } on DioException catch (e) {
          return handler.reject(e);
        }
      }
    }
    super.onResponse(response, handler);
  }
}

/// 打印日志
class LoggingInterceptor extends Interceptor {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    Log().debug('-------------------- Start --------------------');
    if (options.queryParameters.isEmpty) {
      Log().debug('RequestUrl: ${options.baseUrl}${options.path}');
    } else {
      Log().debug(
        'RequestUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}',
      );
    }
    Log().debug('RequestMethod: ${options.method}');
    Log().debug('RequestHeaders:${options.headers}');
    Log().debug('RequestContentType: ${options.contentType}');
    Log().debug('RequestData: ${options.data.toString()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandler.success) {
      Log().debug('ResponseCode: ${response.statusCode}');
    } else {
      Log().debug('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    Log().debug('返回数据：${response.data}');
    Log().debug('-------------------- End: $duration 毫秒 --------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log().debug('-------------------- Error --------------------');
    super.onError(err, handler);
  }
}
