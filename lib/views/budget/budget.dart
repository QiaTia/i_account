import 'package:flutter/material.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String remainingBudget = '-22.00';
  String monthlyBudget = '0.00';
  String monthlyExpense = '22.00';

  void showBudgetInputDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('请输入月度预算'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '请输入'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('确定'),
              onPressed: () {
                setState(() {
                  monthlyBudget = controller.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2025年03月总预算'),
        actions: [
          TextButton(
            onPressed: () {
              // 编辑功能
              showBudgetInputDialog(context);
            },
            child: const Text('编辑', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 40,
                  child: const Text('已超支', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('剩余预算:', style: TextStyle(fontSize: 18)),
                          Text(remainingBudget, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('本月预算:', style: TextStyle(fontSize: 18)),
                          Text(monthlyBudget, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('本月支出:', style: TextStyle(fontSize: 18)),
                          Text(monthlyExpense, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showBudgetInputDialog(context);
                },
                child: const Text('请输入月度预算'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}