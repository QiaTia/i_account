import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/common/Widget/base.dart';
import 'package:i_account/common/base/item_icon.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/set.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/utils/date.dart';
import 'package:i_account/views/home/Widget/datePicker.dart';
import 'package:fl_chart/fl_chart.dart';

/// 统计图表页面
class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  final DBManager $dbManager = DBManager();

  /// 默认选中“支出”
  CategoryType selectedCategoryType = CategoryType.expense;
  double totalAmount = 0.0;

  /// 按日期归档数据
  Map<String, double> groupedData = {};

  /// 排行榜数据
  List<CategoryStatistics> rankingData = [];

  /// 选择类别
  void onSelected(CategoryType value) {
    setState(() {
      selectedCategoryType = value;
    });
  }

  /// 初始化数据
  void initData((String, String, int) selected) {
    $dbManager
        .selectRecordByCondition(
            selected.$1, selected.$2, selectedCategoryType, selected.$3)
        .then((result) {
      // 处理查询结果
      setState(() {
        rankingData = result.$1;
        totalAmount = result.$3;
        groupedData = result.$2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appContent = Theme.of(context);
    return Scaffold(
        appBar: ExpenditureAppBar(
          selectedCategoryType: selectedCategoryType,
          onSelected: onSelected,
        ),
        body: Column(children: [
          HeaderWidget(onDate: initData),
          Expanded(
            child: Container(
              color: appContent.cardColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('总支出: ${formatNumber(totalAmount)} 元'),
                        Text(
                            '平均值: ${formatNumber(totalAmount / groupedData.length)} 元')
                      ]),
                  const SizedBox(height: 8),
                  SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: groupedData.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : LineChartWidget(data: groupedData)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('支出排行榜',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: rankingData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: rankingData.length,
                            itemBuilder: (context, index) {
                              final item = rankingData[index];
                              return ListTile(
                                leading: CircleItemIcon(name: item.icon),
                                title: Text(item.name),
                                subtitle: Text(
                                    '${formatNumber(item.totalAmount / totalAmount * 100)} %'),
                                trailing:
                                    Text('${formatNumber(item.totalAmount)} 元'),
                              );
                            },
                          )
                        : const Center(child: EmptyContent()),
                  )
                ],
              ),
            ),
          )
        ]));
  }
}

/// 顶部日期选择栏
class HeaderWidget extends StatefulWidget {
  final void Function((String, String, int) selected)? onDate;
  const HeaderWidget({super.key, this.onDate});
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

/// 折线图组件
class LineChartWidget extends StatelessWidget {
  final noAxisTitles = const AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  );
  final Map<String, double> data;
  List<(String, double)> get groupedData =>
      data.keys.map((e) => (e, data[e]!)).toList();
  const LineChartWidget({super.key, required this.data});

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        rightTitles: noAxisTitles,
        topTitles: noAxisTitles,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (groupedData.length / 12).ceilToDouble(),
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // interval: 4,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).primaryColor;
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Theme.of(context).primaryColorLight,
          )
        ),
        titlesData: titlesData,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: appColor.withOpacity(0.4), width: 2),
            left: const BorderSide(color: Colors.transparent),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.2,
            color: appColor,
            barWidth: 2,
            isStrokeCapRound: true,
            // dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            dotData: const FlDotData(show: true),
            spots: List.generate(
              groupedData.length,
              (index) => FlSpot(
                index.toDouble(),
                groupedData[index].$2,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 180),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );
    var keyStr = groupedData[value.toInt()].$1;

    var text =
        keyStr.substring(keyStr.length - (groupedData.length > 7 ? 2 : 5));
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      // fontWeight: FontWeight.w300,
      fontSize: 13,
    );
    String text;
    var current = value.toInt();
    if (current > 9e7) {
      text = '${(current / 1e8).toStringAsFixed(1)}E';
    } else if (current > 9e3) {
      text = '${(current / 1e4).toStringAsFixed(1)}M';
    } else if (current > 9e2) {
      text = '${(current / 1e3).toStringAsFixed(1)}K';
    } else {
      text = value.toInt().toString();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}

/// 顶部选择
class ExpenditureAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CategoryType selectedCategoryType;
  final void Function(CategoryType value) onSelected;

  const ExpenditureAppBar(
      {super.key,
      required this.selectedCategoryType,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: PopupMenuButton<CategoryType>(
        position: PopupMenuPosition.under,
        itemBuilder: (context) => [CategoryType.income, CategoryType.expense]
            .map((value) => PopupMenuItem(value: value, child: Text(value.tr)))
            .toList(),
        onSelected: onSelected,
        child: SizedBox(child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(selectedCategoryType.tr),
            const Icon(Icons.arrow_drop_down)
          ]),)
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
