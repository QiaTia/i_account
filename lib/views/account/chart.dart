import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:i_account/common/Widget/base.dart';
import 'package:i_account/common/base/item_icon.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/utils/date.dart';
import 'package:i_account/views/home/Widget/date_picker.dart';
import 'package:fl_chart/fl_chart.dart';

/// 统计图表页面
class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  _ExpenditureScreenState createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  final DBManager $dbManager = DBManager();

  /// 默认选中 “支出”
  CategoryType selectedCategoryType = CategoryType.expense;

  /// 日期筛选模式 0 ｜ 1 ｜ 2
  int dateFilterMode = 0;

  /// 是否按分类查询数据
  bool isCategory = true;

  /// 选中的日期范围
  (DateTime, DateTime) selectedDateRange = (DateTime.now(), DateTime.now());

  /// 总金额
  double totalAmount = 0.0;

  /// 按日期归档数据
  Map<String, double> groupedData = {};

  /// 排行榜数据
  List<CategoryStatistics> rankingData = [];

  /// 选择类别
  void onSelected(CategoryType value) {
    setState(() { selectedCategoryType = value; });
    initData(selectedDateRange);
  }
  /// 
  void onCategory() {
    isCategory = !isCategory;
    initData(selectedDateRange);
  }

  /// 选择时间过滤方式
  void onSelectedFilterMode(int val) {
    setState(() {
      dateFilterMode = val;
    });
  }

  /// 初始化数据
  void initData((DateTime, DateTime) selected) {
    selectedDateRange = selected;
    $dbManager
        .selectRecordByCondition(
            selected.$1, selected.$2, selectedCategoryType, dateFilterMode, isCategory)
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
    return Scaffold(
        appBar: ExpenditureAppBar(onSelected: onSelectedFilterMode, onCategory: onCategory),
        body: Column(children: [
          HeaderWidget(
              dateFilterMode: dateFilterMode,
              onDate: initData,
              onCategoryType: onSelected),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            '${'chart.total'.tr()}: ${'account.unit'.tr()}${formatNumber(totalAmount)}'),
                        Text(
                            '${'chart.average'.tr()}: ${'account.unit'.tr()}${formatNumber(totalAmount / groupedData.length)}')
                      ]),
                  const SizedBox(height: 8),
                  SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: groupedData.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : LineChartWidget(data: groupedData)),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                          '${selectedCategoryType.tr} ${'account.month.rankings'.tr()}',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
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
                                trailing: Text(
                                    '${'account.unit'.tr()}${formatNumber(item.totalAmount)}'),
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
  final int dateFilterMode;
  final void Function((DateTime, DateTime) selected)? onDate;
  final void Function(CategoryType val)? onCategoryType;
  const HeaderWidget(
      {super.key,
      required this.dateFilterMode,
      this.onDate,
      this.onCategoryType});
  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  DateTime selectedDate = DateTime.now();

  /// 选中日期键
  int selectedIndex = 0;

  /// 展示的日期格式
  String get selectedDateStr =>
      formatDate(selectedDate, gap: '.', showLen: widget.dateFilterMode == 1 ? 2 : 1);

  /// 选择月份或年份
  Future<void> onSelectMonth() async {
    final fields = widget.dateFilterMode == 2 ? ['year'] : ['year', 'month'];
    var respond = await showYearMonthPicker(
        context: context, value: selectedDate, fields: fields);
    if (respond != null) {
      setState(() {
        selectedDate = respond;
      });
      if (widget.onDate != null) _calculateDateTupleBubble();
    }
  }

  /// 计算出日期元组冒泡
  void _calculateDateTupleBubble() {
    switch (widget.dateFilterMode) {
      case 0:
        {
          final weekIndex = selectedDate.weekday;

          /// 获得一周的周一
          final monday = selectedDate.subtract(Duration(days: weekIndex - 1));

          /// 获得一周的周日
          final sunday = selectedDate.add(Duration(days: 7 - weekIndex));
          widget.onDate!((monday, sunday));
          break;
        }
      default:
        {
          final year = selectedDate.year;
          final month = widget.dateFilterMode == 2 ? 1 : selectedDate.month;
          final firstDay = DateTime(year, month, 1);
          // 获取当月最后一天
          final lastDay = (widget.dateFilterMode == 2
                  ? DateTime(year + 1, month, 1)
                  : DateTime(year, month + 1, 1))
              .subtract(const Duration(days: 1));
          widget.onDate!((firstDay, lastDay));
        }
    }
  }

  /// 切换周
  void _switchDateStep([int targe = 1]) {
    switch (widget.dateFilterMode) {
      case 0: {
        setState(() {
          selectedDate = selectedDate.add(Duration(days: targe * 7));
        });
      }
      case 1: {
        setState(() {
          selectedDate = DateTime(selectedDate.year, selectedDate.month + targe, selectedDate.day);
        });
      }
      case 2: {
        setState(() {
          selectedDate = DateTime(selectedDate.year + targe, selectedDate.month, selectedDate.day);
        });
      }
    }
    _calculateDateTupleBubble();
  }

  @override
  void initState() {
    super.initState();
    _calculateDateTupleBubble();
  }

  @override
  void didUpdateWidget(state) {
    if (widget.dateFilterMode != state.dateFilterMode) {
      _calculateDateTupleBubble();
    }
    super.didUpdateWidget(state);
  }

  /// 时间选择器
  Widget leftDatePicker() {
    /// 获取当前时间
    final now = DateTime.now();
    if (widget.dateFilterMode != 0) {
      final last = DateTime(selectedDate.year, selectedDate.month + 1, 1).subtract(const Duration(seconds: 1));
      final isDisableNext = last.isAfter(now);
      return Row(children: [
        IconButton(
          onPressed: () {
            _switchDateStep(-1);
          },
          icon: const Icon(Icons.arrow_left_rounded)),
          TextButton(
            onPressed: onSelectMonth,
            child: Row(
              children: [Text(selectedDateStr), const Icon(Icons.arrow_drop_down)],
            )
          ),
          IconButton(
            onPressed: isDisableNext ? null : () {
              _switchDateStep();
            },
          icon: const Icon(Icons.arrow_right_rounded)),
      ]);
    }
    final weekIndex = selectedDate.weekday;

    /// 获得一周的周一
    final monday = selectedDate.subtract(Duration(days: weekIndex - 1));

    /// 获得一周的周日
    final sunday = selectedDate.add(Duration(days: 7 - weekIndex));

    /// 是否禁止下一周
    final isDisableNextWeek = sunday.isAfter(DateTime(now.year, now.month, now.day));
    return Row(
      children: [
      IconButton(
          onPressed: () {
            _switchDateStep(-1);
          },
          icon: const Icon(Icons.arrow_left_rounded)),
      Text([formatDateLeft(monday, gap: '.'), formatDateLeft(sunday, gap: '.')]
          .join('-')),
      IconButton(
          onPressed: isDisableNextWeek ? null : () {
            _switchDateStep();
          },
          icon: const Icon(Icons.arrow_right_rounded))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 40, child: leftDatePicker()),
          Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                  width: 160,
                  child: ButtonGroupWidget(
                      height: 28,
                      items: [CategoryType.expense.tr, CategoryType.income.tr],
                      onTap: (i) {
                        if (widget.onCategoryType != null) {
                          widget.onCategoryType!(CategoryType.fromInt(i + 1));
                        }
                      })))
        ]);
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
    final fontSize = (widget.height / 2 - 4);
    return LayoutBuilder(builder: (_, constraints) {
      double width = 50;
      if (widget.items.length < 4) {
        width = max(constraints.maxWidth / widget.items.length, width);
      }
      print('Parent width: ${constraints.maxWidth}, item width: $width'); 
      return SizedBox(
        height: widget.height,
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
                      constraints: BoxConstraints(minWidth: width),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: _selectedIndex == index
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 2))),
                      child: Text(widget.items[index],
                          style: TextStyle(
                              fontSize: fontSize,
                              color: _selectedIndex == index
                                  ? primaryColor
                                  : Colors.grey[600])),
                    ),
                  );
                }),
          )
        ]));
    });
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

      final fontSize = (widget.height / 2) - 4;

      /// 白色文本样式
      final whiteText = TextStyle(color: Colors.grey[300], fontSize: fontSize);

      /// 默认颜色
      final defaultText =
          TextStyle(color: Theme.of(context).primaryColor, fontSize: fontSize);
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
        )),
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
  /// 选择时间筛选模式
  final void Function(int value) onSelected;

  final void Function() onCategory;


  const ExpenditureAppBar({super.key, required this.onSelected, required this.onCategory});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      'date.week'.tr(),
      'date.month'.tr(),
      'date.year'.tr()
    ];
    return AppBar(
      title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, minWidth: 80), 
              child: NavScrollWidget(items: tabs, onTap: onSelected))
            )),
      actions: [
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          itemBuilder: (context) => ['分类 / 详情']
              .map((value) =>
                  PopupMenuItem(value: value, child: Text(value).tr()))
              .toList(),
          onSelected: (_) {
            print(_);
            // ...
            onCategory();
          },
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.more_horiz)),
        ),
      ],
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
