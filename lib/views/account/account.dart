import 'package:flutter/material.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BalanceScreen();
}

class _BalanceScreen extends State<BalanceScreen> {
  final List<Map<String, String>> data = [
    {'month': '3月', 'income': '0.00', 'expense': '22.00', 'balance': '-22.00'},
    {'month': '2月', 'income': '0', 'expense': '0', 'balance': '0.00'},
    {'month': '1月', 'income': '0', 'expense': '0', 'balance': '0.00'},
  ];
  final appBar = AppBar(
    title: const Text('2025'),
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
  );

  @override
  Widget build(BuildContext context) {
    var safeTopAreaHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    return Scaffold(
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
          Column(children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                children: [
                  Text('结余'),
                  SizedBox(height: 8.0),
                  Text('-22.00', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('收入 0.00'),
                      VerticalDivider(color: Colors.white),
                      Text('支出 22.00'),
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
                        DataCell(Text(data[index]['month']!)),
                        DataCell(Text(data[index]['income']!)),
                        DataCell(Text(data[index]['expense']!)),
                        DataCell(Text(data[index]['balance']!)),
                      ],
                    );
                  }),
                ),
              ),
            )),
          ])
        ]));
  }
}
