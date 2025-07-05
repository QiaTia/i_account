import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/application.dart';

/// 底部详情内容弹出
Future<T?> showModalBottomDetail<T>({required BuildContext context, required Widget child, bool isDark = false}) {
  final nav = Navigator.of(context);

  return showDialog<T>(
    context: context,
    barrierColor: isDark ? Colors.black45 : Colors.black54,
    // shape: const RoundedRectangleBorder(
    //   borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
    // ),
    builder: (BuildContext context) {
      return Consumer(builder: (context, ref, _) {
        /// 获取当前主题颜色
        final primaryColor = ref.watch(currentApplicationProvider.select((app) => app.theme.state.lightTheme().primaryColor));
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Semantics(
                button: true,
                label: 'close',
                onTap: nav.pop,
                child: Container(
                  key: const Key('widget_move_modal_center'),
                  margin: const EdgeInsets.all(12),
                  height: 4,
                  width: 24,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        );
      });
    },
  );
}
