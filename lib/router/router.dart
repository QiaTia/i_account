
import 'package:flutter/material.dart';
import 'package:i_account/views/account/account.dart';
import 'package:i_account/views/account/chart.dart';
import 'package:i_account/views/budget/budget.dart';
import 'package:i_account/views/calc.dart';
import 'package:i_account/views/details/detail.dart';
import 'package:i_account/views/details/details.dart';
import 'package:i_account/views/details/new.dart';
import 'package:i_account/views/game/2048.dart';
import 'package:i_account/views/game/sun.dart';
import 'package:i_account/views/game/word.dart';
// import 'package:i_account/views/home/Widget/account.dart';
// import 'package:i_account/views/login/login.dart';
import 'package:i_account/views/mine/settings.dart';
import 'package:i_account/views/music/player.dart';
import 'package:i_account/views/piece.dart';
import 'package:i_account/views/word.dart';

Map<String, Widget Function(BuildContext)> routes = {
  // '/login': (context) => LoginPage(),
  '/word': (context) => const MyWord(),
  '/game': (context) => const GoGame(),
  '/calc': (context) => CalculatorScreen(),
  '/mine/settings': (context) => const SettingsPage(),
  '/music/player': (_) => MusicPlayerPage(),
  '/2048': (_) => My2048Game(),
  '/game/word': (_) => const GameScreen(),
  '/solar': (_) => const SolarSystem(),
  '/details/details': (context) => DetailPage(type: ModalRoute.of(context)!.settings.arguments as int),
  '/details/new': (context) => const ExpenseScreenPage(),
  '/budget': (_) => const BudgetScreen(),
  '/bill': (_) => const BalanceScreen(),
  '/bill/chart': (_) => const ExpenditureScreen(),
  // '/details/detail/:id': (context) {
  //   final String? idString = ModalRoute.of(context)?.settings.arguments as String?;
  //   final int expenseId = int.tryParse(idString ?? '') ?? 1; // 默认值为1，如果转换失败
  //   return ExpenseDetailScreen(expenseId: expenseId);
  // },
  '/account/new': (_) => const ExpenseScreenPage(),
};
