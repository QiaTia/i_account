import 'package:flutter/material.dart';
import 'package:i_account/common/show_modal/bottom_sheet.dart';
import 'package:i_account/views/mine/import/alipay.dart';

enum ImportMode {
  /// 支付宝
  alipay,
  /// 微信
  wechat,
}

/// 导入方式列表
List<SheetListItemProp<ImportMode>> importModeList = [
  SheetListItemProp(title: 'mine.data_import_alipay', value: ImportMode.alipay),
  SheetListItemProp(title: 'mine.data_import_wechat', value: ImportMode.wechat),
];

/// 选择导入并重定向到页面
void importSheet(BuildContext context) async {
  final nav = Navigator.of(context);
  final result = await showBottomSheetList<ImportMode>(context, importModeList);
  switch (result) {
    case ImportMode.alipay:
      {
        nav.push(MaterialPageRoute(builder: (_) => const ImportAlipay()));
        break;
      }
    case ImportMode.wechat:
      {
        nav.push(MaterialPageRoute(builder: (_) => const ImportAlipay()));
        break;
      }
    default: {
      /// unknown
    }
  }
}
