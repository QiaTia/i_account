import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/common/base/item_icon.dart';
import 'package:i_account/model/enum.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/set.dart';
import 'package:i_account/store/sql.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:i_account/utils/modal.dart';
import 'package:i_account/views/home/Widget/record.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});
  final int expenseId;
  @override
  ConsumerState<ExpenseDetailScreen> createState() => _ExpenseDetailScreen();
}

class _ExpenseDetailScreen extends ConsumerState<ExpenseDetailScreen>  {
  final DBManager db = DBManager();
  RecordDetail? expenseData;
  /// 是否有修改, 用于判断是否需要刷新列表
  bool isChange = false;
  /// 已经刷新国
  bool refIsChange = false;

  /// 回调函数，当数据有变化时调用
  void onChange() {
    if (isChange && !refIsChange) {
      ref.read(refreshHomeProvider.notifier).update();
      refIsChange = true;
    }
  }

  /// 从数据库获取账单详情数据
  void getExpenseDetail() {
    db.selectRecordById(widget.expenseId).then((record) {
      if (record == null) {
        _onBackPressed();
      } else {
        setState(() {
          expenseData = record;
        });
      }
    });
  }

  /// 弹窗确认删除
  void _showDeleteConfirmationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('modal.confirm'.tr() + 'modal.delete'.tr()),
              content: const Text('modal.delete.hint').tr(),
              actions: [
                TextButton(
                  onPressed: () {
                    _onBackPressed();
                  },
                  child: const Text('modal.cancel').tr(),
                ),
                TextButton(
                  onPressed: () {
                    db.deleteRecord(expenseData?.id ?? 0).then((_) {
                      print('delete: $_');
                      isChange = true;
                      _onBackPressed();
                      _onBackPressed();
                    });
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('modal.delete').tr(),
                ),
              ]);
        });
  }

  /// 返回上级
  void _onBackPressed() {
    onChange();
    Navigator.of(context).pop();
  }
  /// 编辑弹窗
  void onEdit() async {
    if (expenseData != null) {
      RecordDetail info = expenseData!;
      await showRecordDialog(
        context: context, 
        record: RecordItem(
          icon: info.icon, 
          id: info.id, 
          amount: info.amount, 
          name: info.name, 
          categoryId: info.categoryId, 
          categoryType: info.categoryType, 
          billDate: info.billDate, 
          remark: info.remark,
        ));
      getExpenseDetail();
      isChange = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getExpenseDetail();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(backgroundColor: Colors.transparent);
    var safeTopAreaHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (isPop, _) async {
        /// PopScope 会监听路由触发的返回，这里需要抛出
        if (isPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        appBar: appBar,
        body: Stack(children: [
          Transform.translate(
            offset: Offset(0, -(safeTopAreaHeight)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor, // 起始颜色
                    // 默认背景色
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: const SizedBox(height: 300, width: double.infinity),
            ),
          ),
          expenseData != null
              ? _buildBodyContent(expenseData!)
              : const Center(child: CircularProgressIndicator())
        ]),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: onEdit,
                child: Text("modal.edit".tr(), style: TextStyle(color: Theme.of(context).hintColor)),
              ),
              TextButton(
                onPressed: _showDeleteConfirmationDialog,
                child: Text("modal.delete".tr(), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildBodyContent(RecordDetail record) {
    return Column(children: [
      SizedBox(
          height: 120,
          child: Column(children: [
            Icon(getItemIcon(record.icon),
                color: Theme.of(context).colorScheme.primary,
                size: 60),
            // Icon(Icons.wallet_giftcard_rounded, size: 60, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(height: 10),
            Text(record.name, style: Theme.of(context).textTheme.bodyLarge)
          ])),
      Expanded(
          child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "account.category",
                record.categoryType.tr),
            _buildDetailRow('account.amount', record.amount.toStringAsFixed(2)),
            _buildDetailRow('account.date',
                '${DateFormat('yyyy/MM/dd').format(record.billDate)} ${WeekName.fromInt(record.billDate.weekday).toString().tr()}'),
            _buildDetailRow('account.channel', record.payName ?? ''),
            _buildDetailRow('account.remark', record.remark),
            record.originInfo.isEmpty ? const SizedBox() : _buildDetailRow('account.origin.channel', record.originInfo),
          ],
        ),
      ))
    ]);
  }

  Widget _buildDetailRow(String label, String value) {
    return InkWell(
      onTap: () {
        showModal(context, value, label.tr());
        // 点击事件
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(children: [
          Text(label.tr(), style: TextStyle(fontSize: 16, color: Colors.grey[700]!)),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold))),
        ]),
      ));
  }
}
