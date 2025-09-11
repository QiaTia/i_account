import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
/// 选择日期
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

// @riverpod
// DateTime selectDateProvider(Ref ref) => SelectDate();

@riverpod
/// 顶部状态栏高度
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

@riverpod
/// 首页需要刷新数据
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
