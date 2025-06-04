import 'package:flutter/material.dart';

/// 底部详情内容弹出
Future<T?> showModalBottomDetail<T>({required BuildContext context, required Widget child, bool isDark = false}) {
  final nav = Navigator.of(context);

  return showModalBottomSheet<T>(
    context: context,
    barrierColor: isDark ? Colors.black45 : Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
    ),
    builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Semantics(
              button: true,
              label: '返回',
              onTap: nav.pop,
              child: Container(
                key: const Key('widget_move_modal_bottom_sheet'),
                margin: const EdgeInsets.all(12),
                height: 4,
                width: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    },
  );
}
