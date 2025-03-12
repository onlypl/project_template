import 'package:flutter/material.dart';
import 'package:logger/web.dart';

enum NotificationType { info, warn, success, error }

class AppLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      debugPrint(line);
    }
  }
}

class AppLogFilter extends LogFilter {
  static const bool kReleaseMode = false;
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index == Level.info.index;
    } else {
      return true;
    }
  }
}

class Log {
  final _logger = Logger(
    filter: AppLogFilter(),
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 200,
        colors: false,
        printEmojis: true,
        printTime: false,
      ),
    ),
    output: AppLogOutput(),
  );
  void verbose(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  void debug(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  void info(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  void warn(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  void error(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  void fatal(
    dynamic message, [
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.f(message, time: time, error: error, stackTrace: stackTrace);
  }
}
