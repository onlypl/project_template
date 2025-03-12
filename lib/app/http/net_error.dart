//系统错误code
import 'dart:io';

import 'package:dio/dio.dart';

class ExceptionHandler {
  static const int success = 200; // 请求成功的状态码
  static const int success_not_content = 204;
  static const int not_modified = 304;
  static const int unauthorized = 401;
  static const int cookie_expired = 403; //cookie过期user_cookie

  ///
  static const int not_found = 404;
  //播放次数已用完
  static const int play_count_error = -10000;

  static const int net_error = 1000;
  static const int parse_error = 1001;
  static const int socket_error = 1002;
  static const int http_error = 1003;
  static const int connect_timeout_error = 1004;
  static const int send_timeout_error = 1005;
  static const int receive_timeout_error = 1006;
  static const int cancel_error = 1007;
  static const int unknown_error = 9999;

  static final Map<int, NetError> _errorMap = <int, NetError>{
    net_error: NetError(net_error, '网络异常，请检查你的网络！'),
    parse_error: NetError(parse_error, '数据解析错误！'),
    socket_error: NetError(socket_error, '网络异常，请检查你的网络！'),
    http_error: NetError(http_error, '服务器异常，请稍后重试！'),
    connect_timeout_error: NetError(connect_timeout_error, '连接超时！'),
    send_timeout_error: NetError(send_timeout_error, '请求超时！'),
    receive_timeout_error: NetError(receive_timeout_error, '响应超时！'),
    cancel_error: NetError(cancel_error, '取消请求'),
    unknown_error: NetError(unknown_error, '未知异常'),
  };

  static NetError handlerException(dynamic error) {
    if (error is DioException) {
      if (error.type.errorCode == 0) {
        return _handlerException(error.error);
      } else {
        return _errorMap[error.type.errorCode]!;
      }
    } else {
      return _handlerException(error);
    }
  }

  static NetError _handlerException(dynamic error) {
    int errorCode = unknown_error;
    if (error is SocketException) {
      errorCode = socket_error;
    }
    if (error is HttpException) {
      errorCode = http_error;
    }
    if (error is FormatException) {
      errorCode = parse_error;
    }
    return _errorMap[errorCode]!;
  }
}

class NetError {
  int code; //接口返回code
  String msg; //返回消息
  NetError(this.code, this.msg);
}

extension DioErrorTypeExtension on DioExceptionType {
  int get errorCode => [
        ExceptionHandler.connect_timeout_error,
        ExceptionHandler.send_timeout_error,
        ExceptionHandler.receive_timeout_error,
        0,
        ExceptionHandler.cancel_error,
        0,
      ][index];
}
