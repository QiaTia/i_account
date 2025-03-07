import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/views/details/detail.dart';
import '../../store/set.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({ super.key });
  @override
  Widget build(context, ref) {
    double total = 0;
    // Navigator.of(context);
    var selectDate = ref.watch(selectDateProvider);
    Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: Text('${selectDate.year}/${selectDate.month.toString().padLeft(2, '0')}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(children: [
              Text('本月总收入', style: Theme.of(context).textTheme.labelMedium),
              Text(total.toString(), style: Theme.of(context).textTheme.titleLarge),
            ],)
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('单笔收入排行', style: Theme.of(context).textTheme.titleMedium),
                ButtonGroupWidget(
                  items: const ['按金额', '按时间'],
                  onTap: (String selected) {
                    print('Selected: $selected');
                  },
                ),
            ])
          ),
          Expanded(
            child: DecoratedBox(decoration: const BoxDecoration(color: Colors.white), child: RecordList(selectDate: selectDate)),
          ),
        ],
      ),
    );
  }
}

class RecordList extends StatefulWidget {
  const RecordList({super.key, required this.selectDate});
  final DateTime selectDate;
  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  List<RecordItem> list = [];
  DBManager db = DBManager();
  /// 获取数据列表
  void getDate() async {
    db.selectRecordList(CategoryType.expense, 1, widget.selectDate.year, widget.selectDate.month)
      .then((newList) {
        setState(() {
          list = newList;
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
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        var it = list[index];
        return ListTile(
          onTap: () {
            Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expenseId: it.id)))
              .then((_) { getDate(); });
          },
          leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(it.icon.isEmpty ? Icons.wallet_giftcard : IconData(int.parse(it.icon), fontFamily: Icons.abc.fontFamily)),
            ),
          title: Text('${it.amount}'),
          subtitle: Text(it.billDate.toIso8601String().replaceAll('T', ' ').replaceAll(RegExp(r'.\d+$'), '')),
          trailing: Text(it.name),
        );
      },
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

class _ButtonGroupWidgetState extends State<ButtonGroupWidget> with SingleTickerProviderStateMixin {
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
        Color backgroundColor = isSelected ? Colors.white : const Color(0xFFF7F7F7);
        Color textColor = isSelected ? Theme.of(context).primaryColor : const Color(0xFF999999);

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
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
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
