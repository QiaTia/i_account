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
  await EasyLocalization.ensureInitialized();
  final dbManager = DBManager();
  await dbManager.openDB('db');
  /// 加载本地配置直接复写
  final app = await loadApplication();
  // currentApplicationProvider.notifier.setApplication(application);
  runApp(ProviderScope(
    overrides: [
      currentApplicationProvider.overrideWith((ref) => ApplicationController(app)),
    ],
    child: EasyLocalization(
      supportedLocales: const [startLocale, Locale('en')],
      // <-- change the path of the translation files
      path: 'assets/translations',
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      child: const MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(context, ref) {
    final application = ref.watch(currentApplicationProvider);
    // final applicationNotifier = ref.read(currentApplicationProvider.notifier);
    // applicationNotifier.setApplication(app);
    // applicationNotifier.setLocale(application.locale);
    // applicationNotifier.setThemeMode(application.themeMode);
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
