import 'package:flutter/material.dart';
import 'result.dart';

/// 是否深色模式
bool isDarkMode(ThemeMode themeMode, BuildContext context) {
  return switch (themeMode) {
    // 需要上下文才能知道是否深色模式
    ThemeMode.system => View.of(context).platformDispatcher.platformBrightness == Brightness.dark,
    ThemeMode.dark => true,
    _ => false,
  };
}

extension LogColorExtension on String {
  String get red => '\x1B[31m$this\x1B[0m';
  String get green => '\x1B[32m$this\x1B[0m';
  String get blue => '\x1B[34m$this\x1B[0m';
}

abstract final class LogUtils {
  static void log(Object? value, {Result<Object?> result = const Result.success(null)}) {
    switch (result) {
      case Success<Object?>():
        print('${'[log success]'.green} ${value}');
      case Error<Object?>():
        print('${'[log error]'.red} ${value}');
    }
  }
}
