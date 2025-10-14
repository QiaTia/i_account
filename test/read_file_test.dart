import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/utils/read_file.dart';
import 'package:i_account/model/record.dart';

void main() {
  group('Read File Utility Tests', () {
    test('GB2312解码测试', () async {
      // 测试数据："中国" → 0xD6D0 0xB9FA
      final bytes = [0xD6, 0xD0, 0xB9, 0xFA];
      final str = await decodeBytes(Uint8List.fromList(bytes), 'gb2312');
      expect(str, equals('中国'));
    });

    test('decodeBytes should decode UTF-8 correctly', () async {
      final bytes = utf8.encode('Hello, 世界');
      final str = await decodeBytes(Uint8List.fromList(bytes), 'utf-8');
      expect(str, equals('Hello, 世界'));
    });

    test('parseRecordItem should parse correctly', () {
      final item = [
        '2023-05-15 10:30:00', // 交易时间
        '交通出行', // 交易分类
        'Test Merchant', // 交易对方
        '', // 对方账号
        'Test goods', // 商品说明
        '支出', // 收/支
        '100.00', // 金额
        '支付宝', // 收/付款方式
        '完成', // 交易状态
        '', // 交易订单号
        '', // 商家订单号
        'Test remark', // 备注
      ];

      final record = parseRecordItem(item);

      expect(record.billDate, equals(DateTime.parse('2023-05-15 10:30:00')));
      expect(record.categoryId, equals(4)); // 交通出行 maps to categoryId 4
      expect(record.categoryType, equals(CategoryType.expense));
      expect(record.amount, equals(100.0));
      expect(record.name, equals('交通出行'));
      expect(record.remark, equals('Test goods Test remark'));
      expect(record.payPlatformId, equals(1)); // 支付宝
    });

    test('parseRecordItem should handle income correctly', () {
      final item = [
        '2023-05-15 10:30:00', // 交易时间
        '工资', // 交易分类
        'Test Employer', // 交易对方
        '', // 对方账号
        'Monthly salary', // 商品说明
        '收入', // 收/支
        '5000.00', // 金额
        '支付宝', // 收/付款方式
        '完成', // 交易状态
        '', // 交易订单号
        '', // 商家订单号
        'May salary', // 备注
      ];

      final record = parseRecordItem(item);

      expect(record.categoryType, equals(CategoryType.income));
      expect(record.amount, equals(5000.0));
      expect(record.name, equals('工资'));
    });
  });
}