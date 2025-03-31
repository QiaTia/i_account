import 'package:easy_localization/easy_localization.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/views/details/detail.dart';
import '../../store/set.dart';

/// 排序key内容
const _sortKeyList = ['按金额', '按时间'];

class DetailPage extends StatefulWidget {
  final int type;
  const DetailPage({super.key, required this.type});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  /// 排序方式: 0: 按金额 1: 按时间
  int sortMode = 0;

  void onSelected(String selected) {
    print('Selected: $selected');
    setState(() {
      sortMode = _sortKeyList.indexOf(selected);
    });
  }
  @override
  Widget build(context) {
    final categoryType = CategoryType.fromInt(widget.type);
    final categoryStr =
        categoryType.toString().replaceAll(RegExp(r"^\w+."), '').tr();
    return Consumer(builder: (context, ref, child) {
      var selectDate = ref.watch(selectDateProvider);
      return Scaffold(
        appBar: AppBar(
            title: Text(
                '${selectDate.year}/${selectDate.month.toString().padLeft(2, '0')}')),
        body: Column(
          children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Text('本月总$categoryStr',
                        style: Theme.of(context).textTheme.labelMedium),
                    _TotalWidget(selectDate: selectDate, type: categoryType)
                    // Text(total.toString(), style: Theme.of(context).textTheme.titleLarge),
                  ],
                )),
            const SizedBox(height: 12),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('单笔$categoryStr排行',
                          style: Theme.of(context).textTheme.titleMedium),
                      ButtonGroupWidget(
                        items: _sortKeyList,
                        onTap: onSelected,
                      ),
                    ])),
            Expanded(
              child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child:
                      RecordList(selectDate: selectDate, type: categoryType, sortMode: sortMode)),
            ),
          ],
        ),
      );
    });
  }
}

/// 颗粒化合计数据组件
class _TotalWidget extends StatefulWidget {
  const _TotalWidget({required this.selectDate, required this.type});
  final DateTime selectDate;
  final CategoryType type;
  @override
  State<_TotalWidget> createState() => _TotalWidgetState();
}

class _TotalWidgetState extends State<_TotalWidget> {
  String total = '0.00';
  final DBManager db = DBManager();
  // 去查询数据
  void getDate() async {
    db.selectRecordTotal(widget.type, widget.selectDate).then((val) {
      setState(() {
        total = val;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Text(total.toString(),
        style: Theme.of(context).textTheme.titleLarge);
  }
}

class RecordList extends StatefulWidget {
  const RecordList({super.key, required this.selectDate, required this.type, required this.sortMode,  });
  final DateTime selectDate;
  final CategoryType type;
  final int sortMode;
  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  List<RecordItem> list = [];
  final EasyRefreshController _controller = EasyRefreshController(controlFinishLoad: true);
  DBManager db = DBManager();
  // #todo 分页
  int currentPage = 1;
  /// 是否还有下一页
  bool hasNextPage = true;
  /// 获取数据列表
  void getData() async {
    if (!hasNextPage) {
      _controller.finishLoad(IndicatorResult.noMore);
      return;
    }
    db
      .selectRecordList(widget.type, currentPage++, widget.selectDate.year,
          widget.selectDate.month, widget.sortMode == 0 ? 'amount' : 'bill_date' )
      .then((result) {
        if (result.pageSize * currentPage >= result.total) {
          hasNextPage = false;
          _controller.finishLoad(IndicatorResult.noMore);
        }
        setState(() {
          list.addAll(result.data);
          // list = newList.$1;
        });
      });
  }

  /// 刷新数据
  Future<void> onRefresh() async {
    currentPage = 1;
    hasNextPage = true;
    _controller.finishLoad(IndicatorResult.none);
    setState(() {list = [];});
    await Future.delayed(const Duration(seconds: 1));
    getData();
  }
  /// 去详情页
  void goDetail(RecordItem it) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expenseId: it.id)))
        .then((_) {
      getData();
    });
  }
  @override
  void initState() {
    super.initState();
    onRefresh();
  }
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    /// 时间或者排序方式发生变化
    if (oldWidget.selectDate != widget.selectDate || oldWidget.sortMode != widget.sortMode) {
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _controller,
      onRefresh: onRefresh,
      onLoad: getData,
      child: list.isEmpty ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          var it = list[index];
          return ListTile(
            onTap: () { goDetail(it); },
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(it.icon.isEmpty
                  ? Icons.wallet_giftcard
                  : IconData(int.parse(it.icon),
                      fontFamily: Icons.abc.fontFamily)),
            ),
            title: Text(it.amount.toStringAsFixed(2)),
            subtitle: Text(it.billDate
                .toIso8601String()
                .replaceAll('T', ' ')
                .replaceAll(RegExp(r'.\d+$'), '')),
            trailing: Text(it.name),
          );
        },
      ),
    );
  }
}

/// animation button group
class ButtonGroupWidget extends StatefulWidget {
  final List<String> items;
  final Function(String) onTap;
  final String? current;

  const ButtonGroupWidget({
    super.key,
    required this.items,
    required this.onTap,
    this.current,
  });

  @override
  _ButtonGroupWidgetState createState() => _ButtonGroupWidgetState();
}

class _ButtonGroupWidgetState extends State<ButtonGroupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.current ?? widget.items.first;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant ButtonGroupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _currentSelection = widget.current;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: widget.items.map((item) {
        bool isSelected = item == _currentSelection;
        Color backgroundColor =
            isSelected ? Colors.white : const Color(0xFFF7F7F7);
        Color textColor = isSelected
            ? Theme.of(context).primaryColor
            : const Color(0xFF999999);

        return ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          )),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentSelection = item;
              });
              _animationController.reset();
              _animationController.forward();
              widget.onTap(item);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
