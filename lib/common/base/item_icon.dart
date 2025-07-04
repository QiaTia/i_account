import 'package:flutter/material.dart';

/// Item Icons
Map<String, IconData> _itemIcons = {
  // 餐饮
  'restaurant': Icons.restaurant,
  // 购物
  'shopping': Icons.shopping_cart,
  // 日用
  'daily': Icons.home,
  // 交通
  'transport': Icons.directions_car,
  // 生活居家
  'living': Icons.home,
  // 捐款
  'donation': Icons.favorite,
  // 零食
  'snacks': Icons.fastfood,
  // 运动
  'sports': Icons.fitness_center,
  // 娱乐
  'entertainment': Icons.movie,
  // 通讯
  'communication': Icons.phone_android,
  // 红包
  'red_envelope': Icons.card_giftcard,
  // 医疗
  'medical': Icons.local_hospital,
  // 工资
  'salary': Icons.attach_money,
  // 奖金
  'bonus': Icons.monetization_on,
  // 投资
  'investment': Icons.trending_up,
  // 其他
  'other': Icons.more_horiz,
  // 账单
  'bill': Icons.receipt,
  // 预算
  'budget': Icons.account_balance_wallet,
};

Map<int, String> _itemIntIcons = {
  58674: 'restaurant',
  58780: 'shopping',
  58255: 'daily',
  57815: 'transport',
  58259: 'living',
  58261: 'donation',
  57632: 'snacks',
  57820: 'sports',
  58381: 'entertainment',
  58530: 'communication',
  57693: 'red_envelope',
  57938: 'medical',
  985044: 'salary',
  57662: 'bonus',
  63720: 'investment',
  983263: 'other',
};

/// 获取 Item Icon
/// [iconName] 可以是字符串或整数，整数会被转换为对应的字符串
IconData getItemIcon(String iconName) {
  final int? iconInt = int.tryParse(iconName);
  var iconKey = iconName;
  if (iconInt != null && _itemIntIcons.containsKey(iconInt)) {
    iconKey = _itemIntIcons[iconInt]!;
  }
  if (_itemIcons.containsKey(iconKey)) {
    return _itemIcons[iconKey]!;
  }
  return _itemIcons['budget']!;
}

/// 圆形图标组件
/// [iconName] 图标名称
class CircleItemIcon extends StatelessWidget {
  final String name;
  final double? size;
  const CircleItemIcon({super.key, required this.name, this.size });

  @override
  Widget build(BuildContext context) {
    final appContent = Theme.of(context);
    return CircleAvatar(
      backgroundColor: appContent.primaryColor.withValues(alpha: 0.16),
      child: Icon(getItemIcon(name), color: appContent.colorScheme.primary, size: size),
    );
  } 
}
