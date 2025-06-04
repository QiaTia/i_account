import 'package:flutter/material.dart';

/// 是否深色模式
bool isDarkMode(ThemeMode themeMode, BuildContext context) {
  return switch (themeMode) {
    // 需要上下文才能知道是否深色模式
    ThemeMode.system => View.of(context).platformDispatcher.platformBrightness == Brightness.dark,
    ThemeMode.dark => true,
    _ => false,
  };
}