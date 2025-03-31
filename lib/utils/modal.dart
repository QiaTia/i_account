import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showModal(BuildContext context, String content,
    [String title = 'alert']) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
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
