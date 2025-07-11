
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:i_account/common/show_modal/show_modal_bottom_detail.dart';

/// Sheet 列表项定义
class SheetListItemProp<T> {
  /// 标题
  final String title;
  /// 副标题
  final String? subtitle;
  /// 图标
  final IconData? icon;
  /// 值
  final T value;
  /// 是否可用
  final bool enabled;
  
  SheetListItemProp({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    this.enabled = true,
  });
}

class SheetList<T> extends StatelessWidget {

  final List<SheetListItemProp<T>> items;
  final ValueChanged<T>? onChanged;

  const SheetList({ super.key, required this.items, this.onChanged });
  /// 点击
  void _onChanged(SheetListItemProp<T> item) {
    if (onChanged != null && item.enabled) {
      onChanged!(item.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          title: Text(item.title).tr(),
          onTap: () => _onChanged(item),
          subtitle: item.subtitle  != null ? Text(item.subtitle!).tr() : null,
          leading: item.icon != null ? Icon(item.icon) : null,
        );
    });
  }
}

/// 底部列表
Future<T?> showBottomSheetList<T>(BuildContext context, List<SheetListItemProp<T>> items) {
  final completer = Completer<T>();
  showModalBottomDetail<T>(
    context: context,
    height: 320,
    child: SheetList<T>(items: items, onChanged: (val) {
      completer.complete(val);
      Navigator.of(context).pop();
    },),
  );
  return completer.future;
}
