import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/set.dart';
import 'package:i_account/store/sql.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BalanceScreen();
}

class _BalanceScreen extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (content, ref, child) {
      var selectDate = ref.watch(selectDateProvider);
      print('selectDate: $selectDate');
     
      return Scaffold(
        appBar: AppBar(
          title: Text(selectDate.year.toString()),
          backgroundColor: Colors.transparent,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text('选项1'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('选项2'),
                ),
              ],
              onSelected: (value) {
                // 处理选项选择
              },
            ),
          ],
        ),
        body: Stack(children: [
          const _PageTopBgBar(),
          _DataContent(selectDate: selectDate)
        ]));
    });
  }
}
/// 数据内容
class _DataContent extends StatefulWidget {
  const _DataContent({ required this.selectDate});
  /// 选择的日期
  final DateTime selectDate;
  @override
  State<StatefulWidget> createState() => _DataContentState();
}

class _DataItem {
  /// 收入
  final double income;
  /// 支出
  final double expense;
  /// 结余
  final double balance;
  /// 日期
  final String? month;
  _DataItem({required this.income, required this.expense, required this.balance, this.month });
}
class _DataContentState extends State<_DataContent> {

  final DBManager dbManager = DBManager();
  List<_DataItem> data = [];
  _DataItem totalMap = _DataItem(balance: 0, expense: 0, income: 0);
  /// 获取数据
  void getYearMonthList(DateTime selectDate) async {
    var year = selectDate.year;
    var month = selectDate.month;
    List<_DataItem> list = [];
    double totalIncome = 0;
    double totalExpense = 0;
    double totalBalance = 0;
    for (; month > 0; month--) {
      var select = DateTime(year, month);
      var income = double.parse(await dbManager.selectRecordTotal(CategoryType.income, select));
      var expense = double.parse(await dbManager.selectRecordTotal(CategoryType.expense, select));
      var balance = income - expense;
      totalIncome += income;
      totalExpense += expense;
      totalBalance += balance;
      list.add( _DataItem(month: '${select.month}', income: income, expense: expense, balance: balance));
    }
    setState(() {
      data = list;
      totalMap = _DataItem(income: totalIncome, expense: totalExpense, balance: totalBalance);
    });
  }
  @override
  void initState() {
    super.initState();
    getYearMonthList(widget.selectDate);
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('结余'),
                  const SizedBox(height: 8.0),
                  Text(formatNumber(totalMap.balance), style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('收入 ${formatNumber(totalMap.income)}'),
                      const VerticalDivider(color: Colors.white),
                      Text('支出${formatNumber(totalMap.expense)}'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(color: Colors.white),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('月份')),
                    DataColumn(label: Text('收入')),
                    DataColumn(label: Text('支出')),
                    DataColumn(label: Text('结余')),
                  ],
                  rows: List.generate(data.length, (index) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(data[index].month!)),
                        DataCell(Text(formatNumber(data[index].income))),
                        DataCell(Text(formatNumber(data[index].expense))),
                        DataCell(Text(formatNumber(data[index].balance))),
                      ],
                    );
                  }),
                ),
              ),
            )),
          ]);
  }
}

/// 顶部背景栏
class _PageTopBgBar extends ConsumerWidget {
  const _PageTopBgBar({super.key});
  @override
  Widget build(BuildContext context, ref) {
    var safeTopAreaHeight = ref.watch(safeTopAreaHeightProvider);
    return Transform.translate(
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
          );
  }
}
