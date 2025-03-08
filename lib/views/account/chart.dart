import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:i_account/model/record.dart';
// import 'package:fl_chart/fl_chart.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  CategoryType selectedCategoryType = CategoryType.expense; // 默认选中“支出”
  int selectedTabIndex = 1; // 默认选中“月”标签

  final List<Map<String, dynamic>> expenditureData = [
    {'date': '1', 'value': 0.0},
    {'date': '2', 'value': 0.0},
    {'date': '3', 'value': 0.0},
    {'date': '4', 'value': 0.0},
    {'date': '5', 'value': 22.0},
    {'date': '6', 'value': 0.0},
  ];

  final List<Map<String, dynamic>> rankingData = [
    {'name': '其他耗材成本', 'percentage': 100.00, 'amount': 22.00},
  ];

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: PopupMenuButton<CategoryType>(
          // icon: const Icon(Icons.arrow_drop_down),
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [CategoryType.income, CategoryType.expense]
              .map((value) => PopupMenuItem(
                  value: value,
                  child: Text(value.toString().replaceAll(RegExp(r"^\w+."), ''))
                      .tr()))
              .toList(),
          onSelected: (value) {
            // 处理选项选择
            setState(() {
              selectedCategoryType = value;
            });
          },
          child: SizedBox(
            width: 80,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(selectedCategoryType
                  .toString()
                  .replaceAll(RegExp(r"^\w+."), '')
                  .tr()),
              const Icon(Icons.arrow_drop_down)
            ]),
          )),
      backgroundColor: Colors.transparent,
    );
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => onTabSelected(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: 80,
                            decoration: BoxDecoration(
                              color: selectedTabIndex == 0
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Center(
                                child: Text('周',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onTabSelected(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: 80,
                            decoration: BoxDecoration(
                              color: selectedTabIndex == 1
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Center(
                                child: Text('月',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onTabSelected(2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: 80,
                            decoration: BoxDecoration(
                              color: selectedTabIndex == 2
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Center(
                                child: Text('年',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DropdownButton<String>(
                          value: '2025',
                          items: <String>['2025'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (_) {},
                        ),
                        const Text('1月'),
                        const Text('上月'),
                        const Text('本月'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('总支出: 22.00'),
                    const Text('平均值: 3.67'),
                    const SizedBox(height: 16.0),
                    // LineChartWidget(data: expenditureData),
                    const SizedBox(height: 16.0),
                    const Text('支出排行榜', style: TextStyle(fontSize: 18)),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: rankingData.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.folder),
                          ),
                          title: Text(rankingData[index]['name']),
                          subtitle:
                              Text('${rankingData[index]['percentage']}%'),
                          trailing:
                              Text(rankingData[index]['amount'].toString()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]));
  }
}

// class LineChartWidget extends StatelessWidget {
//   final List<Map<String, dynamic>> data;

//   LineChartWidget({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.7,
//       child: LineChart(
//         LineChartData(
//           minX: 0,
//           maxX: data.length.toDouble() - 1,
//           minY: 0,
//           maxY: 25,
//           titlesData: FlTitlesData(
//             show: true,
//             bottomTitles: AxisTitles(sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 22,
//               // getTextStyles: (value) => const TextStyle(
//               //   color: Color(0xff72719b),
//               //   fontWeight: FontWeight.bold,
//               //   fontSize: 16,
//               // ),
//               // getTitles: (value) {
//               //   if (value.toInt() < data.length) {
//               //     return data[value.toInt()]['date'];
//               //   }
//               //   return '';
//               // },
//               // margin: 8,
//             )),
//             leftTitles: AxisTitles(sideTitles: SideTitles(
//               showTitles: true,
//               // getTextStyles: (value) => const TextStyle(
//               //   color: Color(0xff72719b),
//               //   fontWeight: FontWeight.bold,
//               //   fontSize: 14,
//               // ),
//               // getTitles: (value) {
//               //   return value.toInt().toString();
//               // },
//               reservedSize: 28,
//               // margin: 12,
//             ),
//           )),
//           borderData: FlBorderData(
//             show: true,
//             border: Border.all(color: const Color(0xff37434d)),
//           ),
//           lineBarsData: [
//             LineChartBarData(
//               spots: data.map((item) {
//                 return FlSpot(data.indexOf(item).toDouble(), item['value'].toDouble());
//               }).toList(),
//               isCurved: true,
//               // colors: [Colors.blue],
//               color: Colors.blue,
//               barWidth: 4,
//               isStrokeCapRound: true,
//               dotData: FlDotData(
//                 show: true,
//               ),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: Colors.blue,
//                 // colors: [Colors.blue.withOpacity(0.3)],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
