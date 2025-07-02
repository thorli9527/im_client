// lib/utils/log_util.dart
import 'package:flutter/foundation.dart';

class LogUtil {
  static bool _isDebug = kDebugMode; // 控制是否输出日志

  static void d(String tag, String message) {
    if (_isDebug) {
      print("DEBUG | $tag: $message");
    }
  }

  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebug) {
      print("ERROR | $tag: $message");
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }

  static void i(String tag, String message) {
    if (_isDebug) {
      print("INFO | $tag: $message");
    }
  }

  /// 设置日志开关（可用于切换环境）
  static void setLogEnable(bool enable) {
    _isDebug = enable;
  }
}
