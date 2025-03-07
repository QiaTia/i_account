import 'package:flutter/material.dart';
import 'package:i_account/model/record.dart';

import 'package:i_account/store/sql.dart';

/// 打开记录弹窗
void showRecordPopup(BuildContext context) {
  showGeneralDialog(
      context: context,
      // barrierLabel: "Popup",
      // transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const CustomPopup();
      },
      transitionBuilder: (context, a1, a2, widget) {
        final curvedAnimation = CurvedAnimation(parent: a1, curve: Curves.easeInOut);
        // if (curvedAnimation.status != AnimationStatus.forward) {
        //   return widget;
        // }
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: widget,
          ),
        );
      },
    ).then((_) {
      // Optional: Perform any actions after the dialog is closed
      print('Dialog closed');
    });
}

class CustomPopup extends StatefulWidget {
  const CustomPopup({super.key});

  @override
  _CustomPopupState createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  final DBManager db = DBManager();
  List<CategoryItemProvider> items = [];
  /// 关闭弹窗
  void onCloseDialog() {
    Navigator.pop(context);
  }
  /// 获取分类列表
  void getCategoryList() async {
    db.queryCategoryList().then((list) {
      setState(() {
        items = list;
      });
    });
  }
  @override
  void initState() {
    super.initState();
    getCategoryList();
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height / 2;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.bottomCenter,
      child: Container(
        height: screenHeight,
        padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.transparent,
                ),
                onPressed: () {},
              ),
              const Text('添加记录',
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCloseDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: 
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  print(items[index].id);
                },
                child: RecordItem(item: items[index])
              ),
            )
          )
        ]),
      ),
    );
  }
}

/// 项目
class RecordItem extends StatelessWidget {
  final CategoryItemProvider item;

  const RecordItem({ super.key, required this.item });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconData(int.parse(item.icon), fontFamily: Icons.abc.fontFamily), size: 30),
            const SizedBox(height: 10),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
    );
  }
}
