import 'package:easy_localization/easy_localization.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/common/base/item_icon.dart';
import 'package:i_account/common/widget/base.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/views/details/detail.dart';
import '../../store/set.dart';

/// 排序key内容
const _sortKeyList = ["account.rank.time", "account.rank.amount"];

class DetailPage extends StatefulWidget {
  final int type;
  const DetailPage({super.key, required this.type});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  /// 排序方式: 0: 按时间 1: 按金额
  int sortMode = 0;
  /// 选择排序方式
  void onSelected(String selected) {
    print('Selected: $selected');
    setState(() {
      sortMode = _sortKeyList.indexOf(selected);
    });
  }
  @override
  Widget build(context) {
    final bgCardColor = Theme.of(context).cardColor;
    final categoryType = CategoryType.fromInt(widget.type);
    final categoryStr = categoryType.tr;
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
                decoration: BoxDecoration(color: bgCardColor),
                child: Column(
                  children: [
                    Text('${"account.month.allAmount".tr()} $categoryStr',
                        style: Theme.of(context).textTheme.labelMedium),
                    _TotalWidget(selectDate: selectDate, type: categoryType)
                    // Text(total.toString(), style: Theme.of(context).textTheme.titleLarge),
                  ],
                )),
            const SizedBox(height: 12),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: bgCardColor),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$categoryStr ${"account.month.rankings".tr()}',
                          style: Theme.of(context).textTheme.titleMedium),
                      ButtonGroupWidget(
                        items: _sortKeyList,
                        onTap: onSelected,
                      ),
                    ])),
            Expanded(
              child: DecoratedBox(
                  decoration: BoxDecoration(color: bgCardColor),
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

class RecordList extends ConsumerStatefulWidget {
  final DateTime selectDate;
  final CategoryType? type;
  final int sortMode;

  const RecordList({super.key, required this.selectDate, this.type, this.sortMode = 0 });
  @override
  ConsumerState<RecordList> createState() => _RecordListState();
}

class _RecordListState extends ConsumerState<RecordList> {
  List<RecordItem> list = [];
  final EasyRefreshController _controller = EasyRefreshController(controlFinishLoad: true);
  DBManager db = DBManager();
  // #todo 分页
  int currentPage = 0;
  /// 是否还有下一页
  bool hasNextPage = true;
  /// 获取数据列表
  void getData() async {
    if (!hasNextPage) {
      _controller.finishLoad(IndicatorResult.noMore);
      return;
    }
    db
      .selectRecordList(widget.type, ++currentPage, widget.selectDate.year,
          widget.selectDate.month, widget.sortMode == 0 ? 'bill_date' : 'amount' )
      .then((result) {
        final isNext = result.pageSize * currentPage >= result.total;
        /// 这个组建好像有bug，不手动这些none后续无法触发下一页
        _controller.finishLoad(isNext ? IndicatorResult.noMore : IndicatorResult.none);
        setState(() {
          list.addAll(result.data);
          hasNextPage = !isNext;
          // list = newList.$1;
        });
      }).catchError((_) {
        _controller.finishLoad(IndicatorResult.fail);
      });
  }

  /// 刷新数据
  Future<void> onRefresh() async {
    currentPage = 0;
    _controller.finishLoad(IndicatorResult.none);
    setState(() {
      hasNextPage = true;
      list = [];
    });
    await Future.delayed(const Duration(seconds: 1));
    getData();
  }
  /// 去详情页
  void goDetail(RecordItem it) {
    Navigator.of(context)
      .push<bool?>(MaterialPageRoute(
          builder: (_) => ExpenseDetailScreen(expenseId: it.id)));
      // .then((isChange) {
      //   /// 如果有修改则刷新列表;
      //   if (isChange == true) {
      //     onRefresh();
      //   }
      // });
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
    final appContent = Theme.of(context);
    ref.listen(refreshHomeProvider, (_, _1) {
      onRefresh();
    });
    return EasyRefresh(
      controller: _controller,
      onRefresh: onRefresh,
      onLoad: getData,
      child: list.isEmpty ? 
        hasNextPage ? const Center(child: CircularProgressIndicator()) : const EmptyContent() : 
        ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          var it = list[index];
          return ListTile(
            onTap: () { goDetail(it); },
            leading: CircleItemIcon(name: it.icon),
            title: Text(it.amount.toStringAsFixed(2)),
            subtitle: Text(it.remark,
              overflow: TextOverflow.ellipsis,
              style: appContent.textTheme.bodySmall!
                .copyWith(color: appContent.dividerColor),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('yyyy/MM/dd').format(it.billDate)),
                Text(it.name)
            ]),
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
        var smallTextColor = Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF999999);
        Color backgroundColor = Theme.of(context).cardColor;
        Color textColor = isSelected
            ? Theme.of(context).primaryColor
            : smallTextColor;

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
                  color: textColor.withValues(alpha: 0.64),
                  width: 1.0,
                ),
              ),
              child: Text(
                item.tr(),
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
