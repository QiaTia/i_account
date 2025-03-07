import 'package:flutter/material.dart';

class ExpenseScreenPage extends StatefulWidget {
  const ExpenseScreenPage({super.key});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreenPage> {
  int selectedTabIndex = 0; // 默认选中“支出”标签

  final TextEditingController _amountController = TextEditingController(text: '0.00');
  final TextEditingController _descriptionController = TextEditingController();

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('默认账本'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 编辑功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => onTabSelected(0),
                    child: Text(
                      '支出',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedTabIndex == 0 ? Colors.red : Colors.black,
                        decoration: selectedTabIndex == 0 ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onTabSelected(1),
                    child: Text(
                      '收入',
                      style: TextStyle(
                        fontSize: 18,
                        color: selectedTabIndex == 1 ? Colors.red : Colors.black,
                        decoration: selectedTabIndex == 1 ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(16.0),
              children: List.generate(12, (index) {
                String categoryName = '';
                IconData categoryIcon = Icons.ac_unit;

                switch (index) {
                  case 0:
                    categoryName = '餐饮';
                    categoryIcon = Icons.restaurant;
                    break;
                  case 1:
                    categoryName = '购物';
                    categoryIcon = Icons.shopping_cart;
                    break;
                  case 2:
                    categoryName = '日用';
                    categoryIcon = Icons.local_convenience_store;
                    break;
                  case 3:
                    categoryName = '交通';
                    categoryIcon = Icons.directions_car;
                    break;
                  case 4:
                    categoryName = '蔬菜';
                    categoryIcon = Icons.local_florist;
                    break;
                  case 5:
                    categoryName = '水果';
                    categoryIcon = Icons.local_grocery_store; // 替换为合适的图标
                    break;
                  case 6:
                    categoryName = '零食';
                    categoryIcon = Icons.cake;
                    break;
                  case 7:
                    categoryName = '运动';
                    categoryIcon = Icons.directions_run;
                    break;
                  case 8:
                    categoryName = '娱乐';
                    categoryIcon = Icons.movie;
                    break;
                  case 9:
                    categoryName = '通讯';
                    categoryIcon = Icons.phone;
                    break;
                  case 10:
                    categoryName = '服饰';
                    categoryIcon = Icons.checkroom;
                    break;
                  case 11:
                    categoryName = '美容';
                    categoryIcon = Icons.face;
                    break;
                }

                return Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(categoryIcon, color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(categoryName),
                  ],
                );
              }),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.account_balance_wallet),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: '点击输入备注...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text('¥${_amountController.text}'),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          // 拍照功能
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      ...List.generate(10, (index) {
                        return ElevatedButton(
                          onPressed: () {
                            // 数字键盘操作
                          },
                          child: Text((index + 1).toString()),
                        );
                      }),
                      ElevatedButton(
                        onPressed: () {
                          // 小数点操作
                        },
                        child: const Text('.'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 清除操作
                        },
                        child: const Text('C'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 完成操作
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
