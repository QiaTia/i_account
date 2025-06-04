import 'package:easy_localization/easy_localization.dart';

/// 收支分类枚举: 1支出 2收入
enum CategoryType {
  /// 支出
  expense(1),
  /// 收入
  income(2);

  final int state;

  String get tr {
    return toString().replaceAll(RegExp(r"^\w+."), '').tr();
  }
  
  // 可以添加具体的枚举值
  const CategoryType(this.state);

  static CategoryType fromInt(int value) {
    for (CategoryType status in CategoryType.values) {
      if (status.state == value) {
        return status;
      }
    }
    return CategoryType.expense;
  }
}
/// 记录项目
class RecordItem {
  /// 记录ID
  final int id;
  /// 金额
  final double amount;
  /// 记录名称
  final String name;
  /// 分类ID
  final int categoryId;
  /// 分类类型: 1支出 2收入
  final CategoryType categoryType;
  /// 账单日期,方便做数据统计
  final DateTime billDate;
  /// icon
  final String icon;
  /// 备注
  final String remark;
  /// 支付平台ID
  final int? payPlatformId;
  /// 
  final String? originInfo;
  // 记录项目
  RecordItem({ required this.icon, this.originInfo, this.payPlatformId, required this.id, required this.amount, required this.name, required this.categoryId, required this.categoryType, required this.billDate, required this.remark });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'name': name,
      'category_id': categoryId,
      'categoryType': categoryType.state,
      'bill_date': billDate.toIso8601String(),
      'remark': remark,
      'icon': icon,
      'pay_platform_id': payPlatformId,
      'origin_info': originInfo
    };
  }
  static RecordItem fromJson(Map<String, dynamic> info) {
    return RecordItem(
      id: info['id'],
      amount: info['amount'],
      name: info['name'],
      categoryId: info['category_id'],
      categoryType: CategoryType.fromInt(info['category_type']),
      billDate: DateTime.parse(info['bill_date']),
      remark: info['remark'],
      icon: info['icon'] ?? '',
      payPlatformId: info['pay_platform_id'],
      originInfo: info['origin_info']?? ''
    );
  }
}
/// 记录详情 包含其他表信息
class RecordDetail extends RecordItem {
  /// 账单年月,方便做数据统计
  final int billMonth;
  /// 账单年月,方便做数据统计
  final int billYear;
  /// 创建时间
  final DateTime createdAt;
  /// 更新时间
  final DateTime updatedAt;
  /// 是否已删除 0:未删除 1:已删除
  final int isDeleted;
  /// 其他原始信息, 如平台导入原始信息
  final String originInfo;
  /// 支付平台名称
  final String? payName;
  /// 支付平台图标
  final String? payIcon;

  RecordDetail({required this.billMonth, this.payIcon, this.payName, required this.billYear, required this.createdAt, required this.updatedAt, required this.isDeleted, required this.originInfo, required super.id, required super.amount, required super.name, required super.categoryId, required super.categoryType, required super.billDate, required super.icon, required super.remark});
  
  static RecordDetail fromJson(Map<String, dynamic> info) {
    return RecordDetail(
      billMonth: info['bill_month'],
      billYear: info['bill_year'],
      createdAt: DateTime.parse(info['created_at']),
      updatedAt: DateTime.parse(info['updated_at']),
      isDeleted: info['is_deleted'],
      originInfo: info['origin_info'] ?? '',
      id: info['id'],
      amount: info['amount'],
      name: info['name'],
      categoryId: info['category_id'],
      categoryType: CategoryType.fromInt(info['category_type']),
      billDate: DateTime.parse(info['bill_date']),
      remark: info['remark'],
      icon: info['icon'] ?? '',
      payName: info['pay_name'],
      payIcon: info['pay_icon']
    );
  }
  @override
  Map<String, dynamic> toMap() {
    return {
      'bill_month': billMonth,
      'bill_year': billYear,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'origin_info': originInfo,
      'id': id,
      'amount': amount,
      'name': name,
      'category_id': categoryId,
      'category_type': categoryType.state,
      'bill_date': billDate.toIso8601String(),
      'remark': remark,
      'icon': icon,
      'pay_name': payName,
      'pay_icon': payIcon
    };
  }
}

/// 分类类型
class CategoryItemProvider {
  /// 分类ID
  final int? id;
  /// 分类名称
  final String name;
  /// 分类类型: 1支出 2收入
  final CategoryType type;
  /// 分类图标
  final String icon;
  /// 排序
  final int sortNum;
  /// 创建时间
  final DateTime? createdAt;
  /// 更新时间
  final DateTime? updatedAt;

  // 构造函数，初始化
  CategoryItemProvider({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.sortNum,
    this.createdAt,
    this.updatedAt,
  });
  // 从Map转换为CategoryItemProvider
  factory CategoryItemProvider.fromJson(Map<String, dynamic> map) {
    return CategoryItemProvider(
      id: map['id'],
      name: map['name'],
      type: CategoryType.fromInt(map['type']),
      icon: map['icon'],
      sortNum: map['sort_num'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
  // 从Map转换为CategoryItemProvider
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.state,
      'icon': icon,
      'sort_num': sortNum,
      'created_at': DateFormat('yyyy-MM-dd').format(createdAt!),
      'updated_at': updatedAt != null ? DateFormat('yyyy-MM-dd').format(updatedAt!) : null,
    };
  }
}

/// 按分类统计数据
class CategoryStatistics extends CategoryItemProvider {
  /// 统计金额
  final double totalAmount;

  CategoryStatistics({
    required super.id,
    required super.name,
    required super.type,
    required super.icon,
    required this.totalAmount,
    super.sortNum = 0,
  });
}
