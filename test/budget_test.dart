import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/model/budget.dart';

void main() {
  group('BudgetModel Tests', () {
    test('BudgetModel should be created correctly', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        amount: 1000.0,
        budgetMonth: 5,
        budgetYear: 2023,
        createdTime: now,
      );

      expect(budget.amount, equals(1000.0));
      expect(budget.budgetMonth, equals(5));
      expect(budget.budgetYear, equals(2023));
      expect(budget.createdTime, equals(now));
      expect(budget.isDeleted, equals(0));
    });

    test('BudgetModel.fromJson should parse JSON correctly', () {
      final json = {
        'id': 1,
        'amount': 1000.0,
        'budget_month': 5,
        'budget_year': 2023,
        'created_time': '2023-05-15T10:30:00.000',
        'updated_time': '2023-05-16T10:30:00.000',
        'is_deleted': 0,
      };

      final budget = BudgetModel.fromJson(json);

      expect(budget.id, equals(1));
      expect(budget.amount, equals(1000.0));
      expect(budget.budgetMonth, equals(5));
      expect(budget.budgetYear, equals(2023));
      expect(budget.createdTime, equals(DateTime.parse('2023-05-15T10:30:00.000')));
      expect(budget.updatedTime, equals(DateTime.parse('2023-05-16T10:30:00.000')));
      expect(budget.isDeleted, equals(0));
    });

    test('BudgetModel.copyWith should create a copy with updated values', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        id: 1,
        amount: 1000.0,
        budgetMonth: 5,
        budgetYear: 2023,
        createdTime: now,
      );

      final updatedBudget = budget.copyWith(amount: 2000.0, isDeleted: 1);

      expect(updatedBudget.id, equals(budget.id));
      expect(updatedBudget.amount, equals(2000.0));
      expect(updatedBudget.budgetMonth, equals(budget.budgetMonth));
      expect(updatedBudget.budgetYear, equals(budget.budgetYear));
      expect(updatedBudget.createdTime, equals(budget.createdTime));
      expect(updatedBudget.isDeleted, equals(1));
    });

    test('BudgetModel.toMap should convert to map correctly', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String();
      final budget = BudgetModel(
        id: 1,
        amount: 1000.0,
        budgetMonth: 5,
        budgetYear: 2023,
        createdTime: now,
        updatedTime: now,
        isDeleted: 1,
      );

      final map = budget.toMap();

      expect(map['id'], equals(1));
      expect(map['amount'], equals(1000.0));
      expect(map['budget_month'], equals(5));
      expect(map['budget_year'], equals(2023));
      expect(map['created_time'], equals(nowString));
      expect(map['updated_time'], equals(nowString));
      expect(map['is_deleted'], equals(1));
    });
  });
}

