import 'package:my_app/api/support/purchase.dart';
import 'global.dart';
import 'config.dart';
import 'package:my_app/views/webview/web.dart';
import 'package:get/get.dart';
/// 菜单分组
const groupEnum = {
  0: '经营在线',
  1: '货物在线',
  2: '伙伴在线',
};

/// 原始菜单列表
final originMenuList = [
  MenuListItem(
    icon: 'data',
    name: '营业数据',
    prefix: () async {
      var refresh = Global.profile.refToken!;
      var t = DateTime.now().microsecond;
      toWebView('$BIURL?refresh=$refresh&t=$t');
      return null;
    },
    access: 'data_kanban',
    group: 0
  ),
  MenuListItem(
    icon: 'board', 
    name: '门店看板', 
    access: 'store_board', 
    prefix: () async {
      var refresh = Global.profile.refToken!;
      var t = DateTime.now().microsecond;
      toWebView('${BIURL}data-board/?refresh=$refresh&t=$t');
      return null;
    }, 
    group: 0),
  MenuListItem(
    icon: 'wallet',
    name: '钱包',
    path: '/pages/wallet/home',
    access: 'wallet',
    group: 0,
  ),
  MenuListItem(
    icon: 'food_safe',
    name: '食安管理',
    path: '/modules/period/layout?isBack',
    access: 'period',
    group: 1,
  ),
  MenuListItem(
    icon: 'intelligent_ordering',
    name: '订货助手',
    path: '/modules/intelligentOrdering/pages/layout',
    access: 'intelligent_ordering',
    group: 1,
  ),
  MenuListItem(
    icon: 'purchase',
    name: '门店采购',
    access: 'store_purchase',
    group: 1,
    prefix: toPurchase,
  ),
  MenuListItem(
    icon: 'stocking',
    name: '库存管理',
    path: '/modules/data/layout',
    access: 'order_stock',
    group: 1,
    prefix: () async {
      var refresh = Global.profile.refToken!;
      var t = DateTime.now().microsecond;
      toWebView('${BIURL}order-stock/?refresh=$refresh&t=$t');
      return null;
    },
  ),
  MenuListItem(
    icon: 'store_stocking',
    name: '茶汤预估',
    path: '/modules/storeStocking/pages/stockList',
    access: 'store_stocking',
    group: 1,
  ),
  MenuListItem(
    icon: 'piece',
    name: '考勤绩效',
    path: '/modules/piece/layout',
    access: 'attendance',
    group: 1,
  ),
  MenuListItem(
    icon: 'account',
    name: '生意参谋',
    path: '/modules/bwzb/home/home',
    access: 'cost_bookkeeping',
    group: 0,
  ),
  MenuListItem(
    icon: 'store',
    name: '门店管理',
    group: 0,
    path: '/modules/mange/storeAdmin/layout',
    access: 'store_manage',
  ),
  MenuListItem(
    icon: 'vocational',
    name: '霸王管家',
    path: '',
    access: 'service_management',
    prefix: () async {
      var result = await loginMsy();
      toWebView(result.data!['data']);
      return null;
    },
  ),
  MenuListItem(
    icon: 'repair',
    name: '在线客服',
    path: '',
    access: 'repair',
    group: 1,
    prefix:  () async {
      var url = await toAliyunContact();
      toWebView(url);
      return null;
    }
  ),
  MenuListItem(
    icon: 'invoice',
    name: '开票管理',
    path: '/modules/wallet/pages/invoice/index',
    access: 'invoice',
    group: 0,
  ),
  MenuListItem(
    icon: 'distributor',
    name: '门店对账',
    path: '/modules/distributor/layout',
    access: 'app_distributor',
    group: 0,
  ),
  MenuListItem(
    icon: 'learning',
    name: '霸王学堂',
    access: 'purchase_learning_platform',
    prefix: () async {
      var data = await getUmuUrl();
      toWebView(data.data![data]);
      return '';
    },
  ),
  MenuListItem(
    icon: 'storledger',
    name: '经营助手',
    path: '/modules/storeLedger/pages/home',
    access: 'store_ledger',
    group: 0,
  ),
  MenuListItem(
    icon: 'workflow',
    name: '门店工单',
    path: '/modules/support/pages/workflow',
    access: 'workflow',
    group: 0,
  ),
  MenuListItem(
    icon: 'privilege_card',
    name: '特权卡提现',
    path: '/modules/wallet/pages/home',
    access: 'privilege_card',
    group: 0,
  ),
  MenuListItem(
    icon: 'calculator',
    name: '薪资计算器',
    path: '/modules/piece/pages/salary/calculator',
    access: 'calculator',
    group: 0,
  ),
  MenuListItem(
    icon: 'see_also',
    name: '违约通知书',
    path: '/modules/mange/storeAdmin/pages/seeAlso',
    access: 'see_also',
    group: 0,
  ),
  MenuListItem(
    icon: 'store_close',
    name: '霸王日清',
    path: '/modules/mange/storeAdmin/pages/ClosingAcceptance',
    access: 'store_close',
    group: 2,
  ),
  MenuListItem(
    icon: 'real_salary',
    name: '实发工资',
    path: '/modules/piece/pages/table',
    access: 'real_salary',
    group: 2,
  ),
  MenuListItem(
    icon: 'payroll',
    name: '工资单',
    path: '/modules/piece/pages/payroll',
    access: 'payroll',
    group: 2,
  ),
  MenuListItem(
    icon: 'store_loss',
    name: '生产报损',
    path: '/modules/goodsOperation/storeLoss/storeLoss',
    access: 'store_loss',
    group: 1,
  ),
];

/// 菜单项目
class MenuListItem {
  /// 菜单图标
  final String icon;
  /// 菜单名称
  final String name;
  /// 页面路径
  final String? path;
  /// 菜单权限
  final String access;
  /// 菜单分组
  final int group;
  /// 预处理方法
  final Future<String?> Function()? prefix;
  MenuListItem({required this.icon, required this.name, this.path, required this.access, this.group = 1, this.prefix });
}

void toWebView(String url) {
  Get.to(() => WebViewPage(url: url));
}