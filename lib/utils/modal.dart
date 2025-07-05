import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<T?> showModal<T>(BuildContext context, String content, [String? title]) async {
  final resolvedTitle = title ?? 'alert'.tr();
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(resolvedTitle),
      content: Text(content),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('modal.ok').tr(),
        ),
      ],
    ),
  );
}