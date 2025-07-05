import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/router/router.dart';
import 'package:i_account/store/application.dart';
import 'package:i_account/views/home/home.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'store/sql.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.ensureInitialized();
  await DBManager().openDB('db');
  /// 加载本地配置直接复写
  final app = await loadApplication();
  runApp(ProviderScope(
    overrides: [
      currentApplicationProvider.overrideWith((ref) => ApplicationController(app)),
    ],
    child: EasyLocalization(
      supportedLocales: supportedLocales,
      // <-- change the path of the translation files
      path: 'assets/translations',
      startLocale: app.locale,
      fallbackLocale: supportedLocales[1],
      child: const MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(context, ref) {
    /// 获取当前配置
    final application = ref.watch(currentApplicationProvider);
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        themeMode: application.themeMode,
        theme: application.theme.state.lightTheme(),
        darkTheme: application.theme.state.darkTheme(),
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: const MyHomePage(),
    );
  }
}
