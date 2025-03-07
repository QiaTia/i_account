import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

const startLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');

@riverpod
class ClickCount extends Notifier<int> {
  // 重写此方法返回Notifier的初始状态
  @override
  int build() => 0;
  /// 自增
  void increment() {
    state++;
  }
  /// 重置
  void reset() {
    state = 0;
  }
}

final clickCountProvider = NotifierProvider<ClickCount, int>(() => ClickCount());


@riverpod
class SelectDate extends Notifier<DateTime> {
  // 重写此方法返回Notifier的初始状态
  @override
  DateTime build() => DateTime.now();
  /// 变更内容
  void update(DateTime t) {
    state = t;
  }
}

final selectDateProvider = NotifierProvider<SelectDate, DateTime>(() => SelectDate());