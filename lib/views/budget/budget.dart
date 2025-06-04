import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/set.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/model/budget.dart';
import 'dart:math';

import 'package:i_account/utils/date.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  /// 月度预算
  double monthlyBudget = 0.00;
  final DBManager dbManager = DBManager();

  /// 设置或更新预算
  void setBudget(double budget, DateTime now) async {
    var value = await dbManager.db.rawQuery(
        'select * from budget where budget_month =? and budget_year =?',
        [now.month, now.year]);
    // 存在则更新
    if (value.isNotEmpty) {
      var newBudget = BudgetModel.fromJson(value.first);
      dbManager.db.rawUpdate(
          'update budget set amount =? where id =?', [budget, newBudget.id]);
    } else {
      dbManager.db.rawInsert(
          'insert into budget (amount, budget_month, budget_year) values (?, ?, ?)',
          [budget, now.month, now.year]);
    }
    setState(() {
      monthlyBudget = budget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (content, ref, child) {
      /// 选择的日期
      DateTime selectedDate = ref.watch(selectDateProvider);
      print("refresh budget screen");

      /// 编辑功能
      void showBudgetInputDialog() async {
        var value = await showInputDialog(context, '请输入月度预算');
        setBudget(value, selectedDate);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${formatDate(selectedDate, showLen: 2)} 预算'),
          actions: [
            TextButton(
              onPressed: showBudgetInputDialog,
              child: const Text('编辑'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BudgetItem(
                  selectedDate: selectedDate,
                  monthlyBudget: monthlyBudget,
                  updataBudget: (val) {
                    setState(() {
                      monthlyBudget = val;
                    });
                  }),
            ],
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }
}

/// 显示输入框
Future<double> showInputDialog(BuildContext context, String tex) {
  final completer = Completer<double>();
  TextEditingController controller = TextEditingController();

  /// 确定
  void onSubmitted() {
    var tex = controller.text;
    if (RegExp('\\D+').hasMatch(tex)) {
      SnackBar snackBar = const SnackBar(content: Text('请输入数字'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    completer.complete(double.parse(tex));
    Navigator.of(context).pop();
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('请输入月度预算'),
        content: TextField(
          controller: controller,
          focusNode: FocusNode(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '请输入'),
          onSubmitted: (_) {
            onSubmitted();
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            onPressed: onSubmitted,
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
  return completer.future;
}

typedef ValueChanged<T> = void Function(T value);

/// 顶部栏
class _BudgetItem extends StatefulWidget {
  final DateTime selectedDate;
  final double monthlyBudget;

  /// 月度预算更新回调
  final ValueChanged<double>? updataBudget;

  const _BudgetItem(
      {required this.selectedDate,
      required this.monthlyBudget,
      this.updataBudget});
  @override
  State<StatefulWidget> createState() => _BudgetItemState();
}

class _BudgetItemState extends State<_BudgetItem> {
  final DBManager dbManager = DBManager();
  double remainingBudget = 0.00;

  /// 月度支出
  double monthlyExpense = 22.00;

  /// 月度预算剩余占比
  double get monthlyBudgetRate =>
      (widget.monthlyBudget - monthlyExpense) / widget.monthlyBudget * 100;

  /// 数据初始化
  void initData() async {
    var expense = double.parse(await dbManager.selectRecordTotal(
        CategoryType.expense, widget.selectedDate));
    setState(() {
      monthlyExpense = expense;
      remainingBudget = widget.monthlyBudget - expense;
    });

    dbManager.db.rawQuery(
        'select * from budget where budget_month = ? and budget_year = ?',
        [widget.selectedDate.month, widget.selectedDate.year]).then((value) {
      if (value.isNotEmpty) {
        var budget = BudgetModel.fromJson(value.first);
        // 。。。
        if (widget.updataBudget != null) widget.updataBudget!(budget.amount);
      }
    });
  }

  // 覆写 didUpdateWidget, 监听数据变更
  @override
  void didUpdateWidget(oldWidget) {
    if (widget.monthlyBudget != oldWidget.monthlyBudget ||
        widget.selectedDate != oldWidget.selectedDate) {
      initData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CircleAvatar(
        //   backgroundColor: Colors.grey[300],
        //   radius: 40,
        //   child: const Text('已超支', style: TextStyle(fontSize: 18)),
        // ),
        BudgetRingChart(rate: monthlyBudgetRate),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('剩余预算:', style: TextStyle(fontSize: 18)),
                  Text(formatNumber(remainingBudget),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('本月预算:', style: TextStyle(fontSize: 18)),
                  Text(formatNumber(widget.monthlyBudget),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('本月支出:', style: TextStyle(fontSize: 18)),
                  Text(formatNumber(monthlyExpense),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 预算环形图
class BudgetRingChart extends StatelessWidget {
  /// 剩余百分比 0 - 100
  final double rate;

  /// 是否无效
  bool get isInvalid => rate < 0 || rate.isInfinite;
  const BudgetRingChart({super.key, this.rate = 98});
  @override
  Widget build(BuildContext context) {
    print("refresh budget ring chart: $rate");
    return Stack(
      children: [
        // SizedBox(
        //   width: 98,
        //   height: 98,
        //   child: CircularProgressIndicator(
        //     value: 1,
        //     strokeWidth: 5,
        //   ),
        // ),
        SizedBox(
            width: 98,
            height: 98,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isInvalid
                  ? [
                      const Text('已超支'),
                    ]
                  : [
                      const Text('剩余'),
                      Text('${formatNumber(rate)}%'),
                    ],
            )),
        AnimatedArc(size: 98, angle: isInvalid ? 0 : rate * 3.6),
      ],
    );
  }
}

/// 自绘的动画圆弧
class AnimatedArc extends StatefulWidget {
  final double size;

  /// 180度，即一半的圆，单位为度，需要转换为弧度
  final double angle;

  /// 动画持续时间，单位为毫秒
  final int duration;

  /// 动画圆弧
  final double strokeWidth;
  const AnimatedArc(
      {super.key,
      this.size = 100,
      this.angle = 180,
      this.duration = 500,
      this.strokeWidth = 5});

  @override
  _AnimatedArcState createState() => _AnimatedArcState();
}

class _AnimatedArcState extends State<AnimatedArc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..forward();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.angle != oldWidget.angle) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _AnimatedArcPainter(_controller,
              radius: widget.size / 2,
              strokeWidth: widget.strokeWidth,
              bgColor: Theme.of(context).cardColor,
              printColor: Theme.of(context).colorScheme.primary,
              angle: widget.angle),
        ));
  }
}

class _AnimatedArcPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;
  final double angle;
  final Color bgColor;
  final double strokeWidth;
  final Color printColor;
  _AnimatedArcPainter(this.animation,
      {required this.radius, required this.strokeWidth, required this.angle, this.printColor = Colors.blue, this.bgColor = Colors.grey})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
        center: Offset(radius, radius), radius: radius - strokeWidth);

    /// 背景圆弧
    final paintBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -pi, 2 * pi, false, paintBg);

    /// 动画圆弧
    Paint paint = Paint()
      ..color = printColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      -pi,
      // 动态调整扫过角度
      animation.value * pi * (angle / 180),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
