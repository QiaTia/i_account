import 'package:flutter/material.dart';
import 'package:i_account/themes/multiple_theme_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class ChangeTheme extends Notifier<MultipleThemeMode> {
  // 重写此方法返回Notifier的初始状态
  @override
  MultipleThemeMode build() => MultipleThemeMode.kDefault;
  /// 自增
  void setTheme(MultipleThemeMode theme) {
    state = theme;
  }
}
/// 当前主题
final currentThemeProvider = NotifierProvider<ChangeTheme, MultipleThemeMode>(() => ChangeTheme());

@riverpod
class ChangeThemeMode extends Notifier<ThemeMode> {
  // 重写此方法返回Notifier的初始状态
  @override
  ThemeMode build() => ThemeMode.system;

  /// 设置主题模式
  void setTheme(ThemeMode mode) {
    state = mode;
  }
  /// 是否是深色模式
  bool get isDarkMode {
    return switch (state) {
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
      ThemeMode.dark => true,
      _ => false,
    };
  }
}

/// 当前主题
final currentThemeModeProvider = NotifierProvider<ChangeThemeMode, ThemeMode>(() => ChangeThemeMode());