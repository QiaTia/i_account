import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/router/router.dart';
import 'package:i_account/views/home/home.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import './store/set.dart';
import 'store/sql.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final dbManager = DBManager();
  await dbManager.openDB('db');
  runApp(ProviderScope(
      child: EasyLocalization(
          supportedLocales: const [startLocale, Locale('en')],
          // <-- change the path of the translation files
          path: 'assets/translations', 
          startLocale: startLocale,
          fallbackLocale: const Locale('en'),
          child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'appTitle'.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey, primary: Colors.blueGrey),
        hintColor: const Color(0xFF132033),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: routes,
      home: const MyHomePage(),
    );
  }
}
