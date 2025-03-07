import 'package:flutter/material.dart';
import 'package:i_account/model/enum.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:easy_localization/easy_localization.dart';

class ExpenseDetailScreen extends StatefulWidget {
  const ExpenseDetailScreen({super.key, this.expenseId});
  final int? expenseId;

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreen();
}

class _ExpenseDetailScreen extends State<ExpenseDetailScreen> {
  final DBManager db = DBManager();
  RecordDetail? expenseData;
  /// 从数据库获取账单详情数据
  void getExpenseDetail() {
    db.selectRecordById(widget.expenseId ?? 1).then((record) {
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
          title: const Text('确认删除'),
          content: const Text('您确定要删除这条账单吗？'),
          actions: [
            TextButton(
              onPressed: () {
                _onBackPressed();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                db.deleteRecord(expenseData?.id ?? 0).then((_) {
                  print('delete: $_');
                  _onBackPressed();
                  _onBackPressed();
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ]
        );
      }
    );
  }
  /// 返回上级
  void _onBackPressed() {
    Navigator.of(context).pop();
  }
  @override
  void initState() {
    super.initState();
    getExpenseDetail();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(backgroundColor: Colors.transparent);
    return Scaffold(
      appBar: appBar,
      body: Stack(children: [
        Transform.translate(
          offset: Offset(0, -(appBar.preferredSize.height)),
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
        expenseData!= null ? _buildBodyContent(expenseData!) : const Center(child: CircularProgressIndicator())
      ]),
    bottomNavigationBar: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {
              // 编辑功能
            },
            child: const Text('编辑', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: _showDeleteConfirmationDialog,
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBodyContent(RecordDetail record) {
  return Column(children: [
    SizedBox(height: 120, child: Column(children: [
      Icon(record.icon.isEmpty ? Icons.wallet_giftcard : IconData(int.parse(record.icon), fontFamily: Icons.abc.fontFamily), size: 60),
      // Icon(Icons.wallet_giftcard_rounded, size: 60, color: Theme.of(context).colorScheme.onPrimary),
      const SizedBox(height: 10),
      Text(record.name, style: Theme.of(context).textTheme.bodyLarge)
    ])),
    Expanded(child: 
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('类型', record.categoryType.toString().replaceAll(RegExp(r"^\w+."), '').tr()),
            _buildDetailRow('金额', record.amount.toString()),
            _buildDetailRow('日期', '${DateFormat('yyyy/MM/dd').format(record.billDate)} ${WeekName.fromInt(record.billDate.weekday).toString().tr()}'),
            _buildDetailRow('备注', record.remark),
            _buildDetailRow('支付渠道', record.payName ?? ''),
          ],
        ),
      )
)]);
}

Widget _buildDetailRow(String label, String value) {
  return Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700]!)),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}