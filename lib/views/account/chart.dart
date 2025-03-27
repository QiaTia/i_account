import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/set.dart';
import 'package:i_account/utils/date.dart';
import 'package:i_account/views/home/Widget/datePicker.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  CategoryType selectedCategoryType = CategoryType.expense; // 默认选中“支出”

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
  void onSelected(CategoryType value) {
    setState(() {
      selectedCategoryType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: PopupMenuButton<CategoryType>(
              // icon: const Icon(Icons.arrow_drop_down),
              position: PopupMenuPosition.under,
              itemBuilder: (context) => [
                    CategoryType.income,
                    CategoryType.expense
                  ]
                      .map((value) => PopupMenuItem(
                          value: value,
                          child: Text(value
                                  .toString()
                                  .replaceAll(RegExp(r"^\w+."), ''))
                              .tr()))
                      .toList(),
              onSelected: onSelected,
              child: SizedBox(
                width: 80,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(selectedCategoryType
                      .toString()
                      .replaceAll(RegExp(r"^\w+."), '')
                      .tr()),
                  const Icon(Icons.arrow_drop_down)
                ]),
              )),
          backgroundColor: Colors.transparent,
        ),
        body: Column(children: [
          HeaderWidget(
            onDate: (selected) {
              print(selected);
            }
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
                const SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: LineChartWidget(data: [],)
                ),
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
                      subtitle: Text('${rankingData[index]['percentage']}%'),
                      trailing: Text(rankingData[index]['amount'].toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ]));
  }
}

/// 顶部日期选择栏
class HeaderWidget extends StatefulWidget {
  final void Function((String, String, int) selected)? onDate;
  const HeaderWidget({ super.key, this.onDate });
  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  DateTime selectedDate = DateTime.now();

  /// 选中的日期类型
  int selectedTabIndex = 0;
  final List<String> tabs = ['周', '月', '年'];

  /// 选中日期键
  int selectedIndex = 0;

  /// 展示的日期格式
  String get selectedDateStr =>
      formatDate(selectedDate, showLen: selectedTabIndex == 0 ? 2 : 1);
  List<(String, String, int)> dateItems = [];
  List<String> get dateStringItems =>
      dateItems.map((e) => "${e.$3}${tabs[selectedTabIndex]}").toList();
  void onSelectDate(int index) {
    var selected = dateItems[index];
    widget.onDate?.call((selected.$1, selected.$2, selectedTabIndex));
  }

  /// 选择月份
  Future<void> onSelectMonth() async {
    final fields = selectedTabIndex == 1 ? ['year'] : ['year', 'month'];
    var respond = await showYearMonthPicker(
        context: context, value: selectedDate, fields: fields);
    if (respond != null) {
      /// 选择年则把月份置于12月
      final targetMonth = selectedTabIndex == 1 ? 13 : respond.month + 1;
      final targetDate = DateTime(respond.year, targetMonth, 1)
          .subtract(const Duration(days: 1));
      setState(() {
        selectedDate =
            targetDate.isAfter(DateTime.now()) ? DateTime.now() : targetDate;
        // selectedIndex = dateItems.indexWhere((element) => element.$1 == respond.year.toString() && element.$2 == respond.month.toString());
      });
      onSelectedDateType(selectedTabIndex);
    }
  }

  /// 选择日期类型
  void onSelectedDateType(int type) {
    switch (type) {
      case 2:
        {
          var list = getYearlyRanges(DateTime.now());
          setState(() {
            dateItems = list;
            selectedTabIndex = type;
            selectedIndex = list.length - 1;
          });
          break;
        }
      case 1:
        {
          var list = getMonthlyRanges(selectedDate);
          setState(() {
            dateItems = list;
            selectedTabIndex = type;
            selectedIndex = list.length - 1;
          });
          break;
        }
      default:
        {
          var list = getWeeksOfMonth(selectedDate);
          setState(() {
            /// 先设置为0，不然可能超限
            selectedIndex = 0;
            dateItems = list;
            selectedTabIndex = type;
          });
          // 延迟五百毫米厚执行
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              selectedIndex = list.length - 1;
            });
          });
        
        }
    }
  }

  @override
  void initState() {
    super.initState();
    onSelectedDateType(0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      var safeTopAreaHeight = ref.watch(safeTopAreaHeightProvider);
      return SizedBox(
          height: 100,
          child: Stack(children: [
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ButtonGroupWidget(
                      items: tabs,
                      onTap: onSelectedDateType,
                    ),
                  ),
                  NavScrollWidget(
                      items: dateStringItems,
                      selected: dateStringItems[selectedIndex],
                      onTap: onSelectDate,
                      leftWidget: selectedTabIndex != 2
                          ? TextButton(
                              onPressed: onSelectMonth,
                              child: Row(
                                children: [
                                  Text(selectedDateStr),
                                  const Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            )
                          : null),
                  const SizedBox()
                ]),
          ]));
    });
  }
}

/// 滑动选择组
class NavScrollWidget extends StatefulWidget {
  final List<String> items;
  final Function(int)? onTap;

  /// 当前选中内容
  final String? selected;

  /// 按钮组的高度
  final double height;

  /// 左边小部件
  final Widget? leftWidget;
  const NavScrollWidget(
      {super.key,
      required this.items,
      this.onTap,
      this.height = 36,
      this.selected,
      this.leftWidget});
  @override
  _NavScrollWidgetState createState() => _NavScrollWidgetState();
}

class _NavScrollWidgetState extends State<NavScrollWidget> {
  int _selectedIndex = 0;
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    // initSelected();
  }

  /// 内容更新进行监听
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      // initSelected();
      onSelected(widget.items.indexOf(widget.selected ?? widget.items[0]));
    }
  }

  /// 内容初始化
  // void initSelected() {
  //   setState(() {
  //     _selectedIndex = widget.items.indexOf(widget.selected?? widget.items[0]);
  //   });
  // }

  /// 内容选中
  void onSelected(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onTap?.call(index);
    var itemWidth =
        _controller.position.maxScrollExtent / (widget.items.length - 2);
    _controller.jumpTo(index * itemWidth);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          widget.leftWidget ?? const SizedBox(),
          Expanded(
            child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => onSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      // width: 120,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: _selectedIndex == index
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 2))),
                      child: Text(widget.items[index],
                          style: TextStyle(
                              color: _selectedIndex == index
                                  ? primaryColor
                                  : Colors.grey[600])),
                    ),
                  );
                }),
          )
        ]));
  }
}

/// 按钮组
class ButtonGroupWidget extends StatefulWidget {
  final List<String> items;
  final Function(int)? onTap;

  /// 当前选中内容
  final String? selected;

  /// 按钮组的圆角
  final double borderRadius;

  /// 按钮组的高度
  final double height;
  const ButtonGroupWidget(
      {super.key,
      required this.items,
      this.onTap,
      this.borderRadius = 6,
      this.height = 36,
      this.selected});
  @override
  _ButtonGroupWidgetState createState() => _ButtonGroupWidgetState();
}

class _ButtonGroupWidgetState extends State<ButtonGroupWidget> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    initSelected();
  }

  /// 内容更新进行监听
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      initSelected();
    }
  }

  /// 内容选中
  void onSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTap?.call(index);
  }

  /// 内容初始化
  void initSelected() {
    setState(() {
      _selectedIndex = widget.items.indexOf(widget.selected ?? widget.items[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      /// 每个按钮的宽度
      final itemWidth = constraints.maxWidth / widget.items.length;

      /// 左边框
      final leftBorder =
          Border(left: BorderSide(color: Theme.of(context).primaryColor));

      /// 白色文本样式
      final whiteText = TextStyle(color: Colors.grey[300]);

      /// 默认颜色
      final defaultText = TextStyle(color: Theme.of(context).primaryColor);
      return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              child: Stack(children: [
                AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: _selectedIndex * itemWidth, // X轴移动
                    curve: Curves.easeIn,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      width: itemWidth,
                      height: widget.height,
                    )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(widget.items.length, ((index) {
                      return Expanded(
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  border: index != 0 ? leftBorder : null),
                              child: InkWell(
                                onTap: () => onSelected(index),
                                child: Center(
                                    child: Text(widget.items[index],
                                        style: _selectedIndex == index
                                            ? whiteText
                                            : defaultText)),
                              )));
                    })))
              ])));
    });
  }
}

class LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const LineChartWidget({super.key, required this.data});

  FlTitlesData get titlesData2 => const FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        // interval: 2,
        // getTitlesWidget: () => Text('hello'),
      ),
    ),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false), axisNameSize: 0),
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false), axisNameSize: 0),
    leftTitles: AxisTitles(
        sideTitles: SideTitles(
      // getTitlesWidget: leftTitleWidgets,
      showTitles: true,
      interval: 3,
      // reservedSize: 40,
    )),
  );

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).primaryColor.withOpacity(0.6);
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: titlesData2,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            // curveSmoothness: 0,
            color: appColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            spots: const [
              FlSpot(1, 1),
              FlSpot(3, 4),
              FlSpot(5, 1.8),
              FlSpot(7, 5),
              FlSpot(10, 2),
              FlSpot(12, 2.2),
              FlSpot(13, 1.8),
            ],
          ),
          // LineChartBarData(
          //   isCurved: true,
          //   // color: AppColors.contentColorPink.withValues(alpha: 0.5),
          //   barWidth: 4,
          //   isStrokeCapRound: true,
          //   dotData: const FlDotData(show: false),
          //   belowBarData: BarAreaData(
          //     show: true,
          //     // color: AppColors.contentColorPink.withValues(alpha: 0.2),
          //   ),
          //   spots: const [
          //     FlSpot(1, 1),
          //     FlSpot(3, 2.8),
          //     FlSpot(7, 1.2),
          //     FlSpot(10, 2.8),
          //     FlSpot(12, 2.6),
          //     FlSpot(13, 3.9),
          //   ],
          // ),
          // LineChartBarData(
          //   isCurved: true,
          //   curveSmoothness: 0,
          //   // color: AppColors.contentColorCyan.withValues(alpha: 0.5),
          //   barWidth: 2,
          //   isStrokeCapRound: true,
          //   dotData: const FlDotData(show: true),
          //   belowBarData: BarAreaData(show: false),
          //   spots: const [
          //     FlSpot(1, 3.8),
          //     FlSpot(3, 1.9),
          //     FlSpot(6, 5),
          //     FlSpot(10, 3.3),
          //     FlSpot(13, 4.5),
          //   ],
          // ),
        ],
        minX: 0,
        maxX: 14,
        maxY: 6,
        minY: 0,
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
