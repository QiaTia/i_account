import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset/charset.dart';
import 'package:excel/excel.dart';
import 'package:i_account/model/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:i_account/store/sql.dart';
import 'package:flutter/foundation.dart' show compute;

Future<String> detectFileEncoding(String filePath) async {
  try {
    // 1. 读取文件字节数据
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    // 2. 检测编码类型 (UTF-8, GBK, etc.) 进行裁剪节约内存
    final encodingName = (Charset.detect(bytes.sublist(0, 1024))?.name ?? 'utf-8').toLowerCase();

    print('Detect Charset: $encodingName');

    // 3. 根据编码解码文本
    return await decodeBytes(bytes, encodingName);
  } catch (e) {
    print('Decode Fail: $e');
    rethrow;
  }
}

/// 解码字节
Future<String> decodeBytes(Uint8List bytes, String encodeName) async {
  if (encodeName.contains('gb') || encodeName.toLowerCase().contains('gbk')) {
    // 使用第三方库解码 GB2312/GBK
    return gbk.decode(bytes);
  } else {
    // 使用 Dart 自带的 UTF-8 解码
    return utf8.decode(bytes);
  }
}

/// 数据处理
List<RecordItem> _paseString(String str) {
  List<List<String>> list = [];
  var len = 0;
  // 对导入的源数据进行拆分
  str.split('\n').reversed.toList().forEach((element) {
    if(element.isNotEmpty) {
      var it = element.split(',');
      //  计算最后的列数
      if (len == 0) {
        len = it.length;
      }
      if (it.length >= len) list.add(it);
    }
  });
  // 取表头数据，建立键值关系
  var tableKey = list.last;
  // for (var i = 0; i < len; i++) {
  // }
  List<RecordItem> newList = [];
  list.reversed.toList().sublist(1).forEach((element) {
    /// #todo 根据现在分类进行解析
    newList.add(parseRecordItem(element));
  });
  print(tableKey);
  return newList;
}
/// 解析记录
RecordItem parseRecordItem(List<String> item) {
  // { 0: 交易时间, 1: 交易分类, 2: 交易对方, 3: 对方账号, 4: 商品说明, 5: 收/支, 6: 金额, 7: 收/付款方式, 8: 交易状态, 9: 交易订单号, 10: 商家订单号, 11: 备注, 12: }
  CategoryType categoryType = item[5].trim() == '支出' ? CategoryType.expense : CategoryType.income;
  var categoryId = 13;
  // 转账红包  数码电器 充值缴费 投资理财 其他 交通出行
  switch (item[1].trim()) {
    case '交通出行':
      categoryId = 4;
      break;
    case '充值缴费':
      categoryId = 10;
      break;
    // case '转账红包':
    //   categoryId = 1;
    //   break;
    case '数码电器':
      categoryId = 2;
      break;
  }
  return RecordItem(
    id: -1,
    amount: double.parse(item[6]),
    name: item[1],
    categoryId: categoryId,
    categoryType: categoryType,
    billDate: DateTime.parse(item[0]),
    remark: '${item[4]} ${item[11]}',
    icon: '',
    payPlatformId: 1,
    originInfo: item.join(',')
  );
}

/// 从文件导入记录
Future<bool> onFileImportRecord() async {
  final DBManager dbManager = DBManager();
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ['csv'],
  ).catchError((err) {
    print('err:$err');
    throw err;
  });
  if (result != null) {
    var str = await detectFileEncoding(result.files.single.path!).catchError((err) {
      print('err:$err');
      throw err;
    });
    var list = _paseString(str);
    for (var element in list) {
      await dbManager.insertRecord(element);
    }
    return true;
  }
  throw 'empty';
}

/// 从本地文件解析记录
Future<List<RecordItem>> importLocalFile2Parse() async {
  var files = await onFilePicker(['csv']);
  var str = await compute(detectFileEncoding, files.single.path!).catchError((err) {
    print('err:$err');
    throw err;
  });
  return _paseString(str);
}

/// 从本地文件解析记录
Future<List<RecordItem>> importLocalFileParseByWechat() async {
  var files = await onFilePicker(['xlsx']);
  return compute(onParseExcel, files.single.path!);
}
/// 拆分函数、把计算逻辑丢到 Isolate
Future<List<RecordItem>> onParseExcel(String path) async{
  List<RecordItem> resultList = [];
  var bytes = File(path).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  for (var table in excel.tables.keys) {
    var sheet = excel.tables[table]!;
    var maxColumns = sheet.maxColumns;
    print('$table -> maxColumns: ${sheet.maxColumns} maxRows: ${sheet.maxRows}'); //sheet Name
    for (var row in sheet.rows) {
      var list = row
        .where((element) => element != null)
        .whereType<Data>()
        .map((cell) => getCellStr(cell))
        .toList();
      if (list.length < maxColumns) continue;
      // 跳过表头
      if (!RegExp(r'\d').hasMatch(list[0] ?? '')) continue;

      resultList.add(parseRecordItemByWechat(list));
    }
  }
  return resultList;
}

/// 打开文件选择器选择指定文件
Future<List<PlatformFile>> onFilePicker(List<String>? allowedExtensions, [bool multiple = false]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: multiple,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
  ).catchError((err) {
    print('err:$err');
    throw err;
  });
  if (result != null) {
    return result.files;
  } else {
    return Future.error('no file');
  }
}


/// 获取单元格内容
String? getCellStr(Data cell) {
  final value = cell.value;
  switch(value) {
    case null:
      return null;
    case TextCellValue():
      return '${value.value}';
    case FormulaCellValue():
      return value.formula;
    case IntCellValue():
      return '${value.value}';
    case BoolCellValue():
      return '${value.value ? 1 : 0}';
    case DoubleCellValue():
      return '${value.value}';
    case DateCellValue():
      return '${value.year} ${value.month} ${value.day} (${value.asDateTimeLocal()})';
    case TimeCellValue():
      return '${value.hour} ${value.minute} ... (${value.asDuration()})';
    case DateTimeCellValue():
      return '${value.year} ${value.month} ${value.day} ${value.hour} ... (${value.asDateTimeLocal()})';
  }
}

/// 解析记录 by wechat
RecordItem parseRecordItemByWechat(List<String?> item) {
  // { 0: 交易时间, 1: 交易分类, 2: 交易对方, 3: 商品, 4:  收/支, 5: 金额, 6: 支付方式, 7: 当前状态, 8: 交易单号, 9: 商户单号, 10: 备注 }
  CategoryType categoryType = item[4]?.trim() == '支出' ? CategoryType.expense : CategoryType.income;
  var categoryId = 3;
  // 转账红包  数码电器 充值缴费 投资理财 其他 交通出行
  switch (item[1]?.trim()) {
    case '商户消费':
      categoryId = ['电费', '生活缴费'].contains(item[5]) ? 10 : 2;
      break;
    // case '转账红包':
    //   categoryId = 1;
    //   break;
    case '转账':
      categoryId = categoryType ==  CategoryType.expense ? 17 : 6;
      break;
  }
  return RecordItem(
    id: -1,
    amount: double.parse(RegExp(r'-?\d*\.?\d+').firstMatch(item[5] ?? '0')?.group(0) ?? '0'),
    name: item[1] ?? '',
    categoryId: categoryId,
    categoryType: categoryType,
    billDate: DateTime.parse(item[0] ?? '2023-01-01'),
    remark: [item[2], item[3], item[10]]
      .where((el) => el != null && el != '/')
      .join(' '),
    icon: '',
    payPlatformId: 2,
    originInfo: item.join(',')
  );
}


// Future<String> readGB2312File(String filePath) async {
//   // 读取文件原始字节
//   final bytes = await File(filePath).readAsBytes();
  
//   // 指定 GB2312 编码进行解码
//   final String content = await CharsetConverter.decode("GB2312", bytes);
  
//   return content;
// }

