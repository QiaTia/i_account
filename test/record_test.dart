import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/model/record.dart';

void main() {
  group('RecordItem Tests', () {
    test('CategoryType should convert from int correctly', () {
      expect(CategoryType.fromInt(1), equals(CategoryType.expense));
      expect(CategoryType.fromInt(2), equals(CategoryType.income));
      expect(CategoryType.fromInt(3), equals(CategoryType.expense)); // default
    });

    test('CategoryType should have correct state values', () {
      expect(CategoryType.expense.state, equals(1));
      expect(CategoryType.income.state, equals(2));
    });

    test('RecordItem should be created correctly', () {
      final date = DateTime.now();
      final record = RecordItem(
        id: 1,
        amount: 100.0,
        name: 'Test',
        categoryId: 1,
        categoryType: CategoryType.expense,
        billDate: date,
        remark: 'Test remark',
        icon: 'test-icon',
        payPlatformId: 1,
        originInfo: 'test-origin',
      );

      expect(record.id, equals(1));
      expect(record.amount, equals(100.0));
      expect(record.name, equals('Test'));
      expect(record.categoryId, equals(1));
      expect(record.categoryType, equals(CategoryType.expense));
      expect(record.billDate, equals(date));
      expect(record.remark, equals('Test remark'));
      expect(record.icon, equals('test-icon'));
      expect(record.payPlatformId, equals(1));
      expect(record.originInfo, equals('test-origin'));
    });

    test('RecordItem.fromJson should parse JSON correctly', () {
      final json = {
        'id': 1,
        'amount': 100.0,
        'name': 'Test',
        'category_id': 1,
        'category_type': 1,
        'bill_date': '2023-05-15T10:30:00.000',
        'remark': 'Test remark',
        'icon': 'test-icon',
        'pay_platform_id': 1,
        'origin_info': 'test-origin',
      };

      final record = RecordItem.fromJson(json);

      expect(record.id, equals(1));
      expect(record.amount, equals(100.0));
      expect(record.name, equals('Test'));
      expect(record.categoryId, equals(1));
      expect(record.categoryType, equals(CategoryType.expense));
      expect(record.billDate, equals(DateTime.parse('2023-05-15T10:30:00.000')));
      expect(record.remark, equals('Test remark'));
      expect(record.icon, equals('test-icon'));
      expect(record.payPlatformId, equals(1));
      expect(record.originInfo, equals('test-origin'));
    });

    test('RecordItem.copyWith should create a copy with updated values', () {
      final date = DateTime.now();
      final record = RecordItem(
        id: 1,
        amount: 100.0,
        name: 'Test',
        categoryId: 1,
        categoryType: CategoryType.expense,
        billDate: date,
        remark: 'Test remark',
        icon: 'test-icon',
        payPlatformId: 1,
        originInfo: 'test-origin',
      );

      final updatedRecord = record.copyWith(
        amount: 200.0,
        name: 'Updated Test',
        categoryType: CategoryType.income,
      );

      expect(updatedRecord.id, equals(record.id));
      expect(updatedRecord.amount, equals(200.0));
      expect(updatedRecord.name, equals('Updated Test'));
      expect(updatedRecord.categoryId, equals(record.categoryId));
      expect(updatedRecord.categoryType, equals(CategoryType.income));
      expect(updatedRecord.billDate, equals(record.billDate));
      expect(updatedRecord.remark, equals(record.remark));
      expect(updatedRecord.icon, equals(record.icon));
      expect(updatedRecord.payPlatformId, equals(record.payPlatformId));
      expect(updatedRecord.originInfo, equals(record.originInfo));
    });

    test('RecordItem.toMap should convert to map correctly', () {
      final date = DateTime.now();
      final dateString = date.toIso8601String();
      final record = RecordItem(
        id: 1,
        amount: 100.0,
        name: 'Test',
        categoryId: 1,
        categoryType: CategoryType.expense,
        billDate: date,
        remark: 'Test remark',
        icon: 'test-icon',
        payPlatformId: 1,
        originInfo: 'test-origin',
      );

      final map = record.toMap();

      expect(map['id'], equals(1));
      expect(map['amount'], equals(100.0));
      expect(map['name'], equals('Test'));
      expect(map['category_id'], equals(1));
      expect(map['categoryType'], equals(1));
      expect(map['bill_date'], equals(dateString));
      expect(map['remark'], equals('Test remark'));
      expect(map['icon'], equals('test-icon'));
      expect(map['pay_platform_id'], equals(1));
      expect(map['origin_info'], equals('test-origin'));
    });
  });
}