/// 预算
class BudgetModel {
  final int? id;
  /// 月度预算金额
  final double amount;
  /// 月度预算月份
  final int budgetMonth;
  /// 月度预算年份
  final int budgetYear;
  /// 创建时间
  final DateTime createdTime;
  /// 更新时间
  final DateTime? updatedTime;
  /// 是否删除 0 未删除 1 删除
  final int isDeleted;

  const BudgetModel({
    this.id,
    required this.amount,
    required this.budgetMonth,
    required this.budgetYear,
    required this.createdTime,
    this.updatedTime,
    this.isDeleted = 0,
  });

  // 将对象转换为 Map (用于数据库操作)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'budget_month': budgetMonth,
      'budget_year': budgetYear,
      'created_time': createdTime.toIso8601String(),
      'updated_time': updatedTime?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  // 从 JSON 创建对象 (用于 API 数据解析)
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      budgetMonth: json['budget_month'] as int,
      budgetYear: json['budget_year'] as int,
      createdTime: DateTime.parse(json['created_time'] as String),
      updatedTime: json['updated_time'] != null 
          ? DateTime.parse(json['updated_time'] as String) 
          : null,
      isDeleted: json['is_deleted'] as int? ?? 0,
    );
  }

  // 可选：添加 copyWith 方法用于对象克隆
  BudgetModel copyWith({
    int? id,
    double? amount,
    int? budgetMonth,
    int? budgetYear,
    DateTime? createdTime,
    DateTime? updatedTime,
    int? isDeleted,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      budgetMonth: budgetMonth ?? this.budgetMonth,
      budgetYear: budgetYear ?? this.budgetYear,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}