import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

const startLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');

// ① 创建一个状态提供者，StateProvider会观察一个值，并再改变时得到通知
// final clickCountProvider = StateProvider<Locale>((ref) => startLocale);

// @Riverpod(keepAlive: true)
// Locale clickCount(ClickCount ref) => startLocale;

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