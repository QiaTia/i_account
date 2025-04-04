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

@riverpod
class SafeTopAreaHeight extends Notifier<double> {
  // 重写此方法返回Notifier的初始状态
  @override
  double build() => 0;
  /// 变更内容
  void update(double t) {
    state = t;
  }
}
final safeTopAreaHeightProvider = NotifierProvider<SafeTopAreaHeight, double>(() => SafeTopAreaHeight());

/// 首页需要刷新数据
@riverpod
class RefreshHome extends Notifier<bool> {
  // 重写此方法返回Notifier的初始状态
  @override
  bool build() => false;
  /// 变更内容
  void update() {
    state = !state;
  }
}
final refreshHomeProvider = NotifierProvider<RefreshHome, bool>(() => RefreshHome());
