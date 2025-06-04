import 'package:flutter/material.dart';

/// 多主题
abstract class AppMultipleTheme {
  /// 亮色
  ThemeData lightTheme();

  /// 深色
  ThemeData darkTheme();
}

/// 主题基础
class AppTheme implements AppMultipleTheme {
//   final BuildContext context;

//   late final applicationViewModel = context.read<ApplicationViewModel>();

  /// 主题模式
  late ThemeMode themeMode = ThemeMode.system;
  AppTheme();

  /// 多主题模式
  // late MultipleThemeMode multipleThemeMode = applicationViewModel.multipleThemeMode;

  /// Static 次要颜色
  static const staticSubColor = Color(0xFFAFB8BF);

  /// Static 背景色系列
  static const staticBackgroundColor1 = Color(0xFFE8ECF0);
  static const staticBackgroundColor2 = Color(0xFFFCFBFC);
  static const staticBackgroundColor3 = Color(0xFFF3F2F3);

  @override
  ThemeData lightTheme() => ThemeData();

  @override
  ThemeData darkTheme() => ThemeData.dark();

  /// 主题模式 FromString
  ///
  /// - [themeMode]: [ThemeMode.system.name]
  static ThemeMode themeModeFromString(String themeMode) => ThemeMode.values.firstWhere(
    (e) => e.name == themeMode,
    orElse: () => ThemeMode.system, // dart format
  );

  /// 是否深色模式
  bool get isDarkMode {
    return switch (themeMode) {
      // 需要上下文才能知道是否深色模式
      // ThemeMode.system => View.of(context).platformDispatcher.platformBrightness == Brightness.dark,
      ThemeMode.dark => true,
      _ => false,
    };
  }
}
