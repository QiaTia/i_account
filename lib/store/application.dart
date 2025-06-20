import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/storage.dart';
import 'package:i_account/themes/multiple_theme_mode.dart';

const startLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');


final currentApplicationProvider = StateNotifierProvider<ApplicationController, Application>(
    (ref) => ApplicationController(Application()));

class ApplicationController extends StateNotifier<Application> {
  ApplicationController(super.state);
  /// 重载应用程序
  void setApplication(Application application) {
    state = application;
  }
  /// 设置主题
  void setTheme(MultipleThemeMode theme) {
    Storage.saveTheme(theme);
    // state.theme = theme;
    state = state.copyWith(theme: theme);
  }
  /// 设置语言
  void setLocale(Locale locale) {
    // Storage.saveLocale(locale);
    state = state.copyWith(locale: locale);
  }
  /// 设置主题模式
  void setThemeMode(ThemeMode themeMode) {
    Storage.saveThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }
  /// 是否是深色模式
  bool get isDarkMode {
    return switch (state.themeMode) {
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
      ThemeMode.dark => true,
      _ => false,
    };
  }
}

/// 应用程序状态管理类
class Application {
  /// 当前应用主题
  MultipleThemeMode theme;
  /// 当前语言
  Locale locale;
  /// 当前主题模式
  ThemeMode themeMode;

  Application({this.theme = MultipleThemeMode.kDefault, this.locale = startLocale, this.themeMode = ThemeMode.system});

  Application copyWith({
    MultipleThemeMode? theme,
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return Application(
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// 加载应用程序状态
Future<Application> loadApplication() async {
  final theme = await Storage.getTheme() ?? MultipleThemeMode.kDefault;
  final themeMode = await Storage.getThemeMode();
  return Application(theme: theme, locale: startLocale, themeMode: themeMode);
}

/// 当前主题模式
// final currentThemeModeProvider = StateProvider((ref) => ThemeMode.system);

// @riverpod
// class ChangeThemeMode extends Notifier<ThemeMode> {
//   // 重写此方法返回Notifier的初始状态
//   @override
//   ThemeMode build() => ThemeMode.system;

//   /// 设置主题模式
//   void setTheme(ThemeMode mode) {
//     Storage.saveThemeMode(mode);
//     state = mode;
//   }
//   /// 是否是深色模式
//   bool get isDarkMode {
//     return switch (state) {
//       ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
//       ThemeMode.dark => true,
//       _ => false,
//     };
//   }
// }

// /// 当前主题
// final currentThemeModeProvider = NotifierProvider<ChangeThemeMode, ThemeMode>(() => ChangeThemeMode());


