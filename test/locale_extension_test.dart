import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/utils/locale_extension.dart';

void main() {
  group('LocaleExtension Tests', () {
    test('Locale.tr should return correct localized names', () {
      // 测试中文
      final zhLocale = const Locale('zh');
      expect(zhLocale.tr, equals('简体中文'));

      // 测试繁体中文（台湾）
      final twLocale = const Locale('zh', 'TW');
      expect(twLocale.tr, equals('繁體中文'));

      // 测试繁体中文（香港）
      final hkLocale = const Locale('zh', 'HK');
      expect(hkLocale.tr, equals('繁體中文'));

      // 测试英文
      final enLocale = const Locale('en');
      expect(enLocale.tr, equals('English'));

      // 测试日文
      final jaLocale = const Locale('ja');
      expect(jaLocale.tr, equals('日本語'));

      // 测试其他语言
      final frLocale = const Locale('fr');
      expect(frLocale.tr, equals('fr'));
      
      final deLocale = const Locale('de', 'DE');
      expect(deLocale.tr, equals('de (DE)'));
    });
  });
}