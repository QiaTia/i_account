import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/utils/date.dart';
import './datePicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/set.dart';

/// 打开记录弹窗
void showRecordPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    // barrierLabel: "Popup",
    // transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return const CustomPopup();
    },
    transitionBuilder: (context, a1, a2, widget) {
      final curvedAnimation =
          CurvedAnimation(parent: a1, curve: Curves.easeInOut);
      // if (curvedAnimation.status != AnimationStatus.forward) {
      //   return widget;
      // }
      return SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(curvedAnimation),
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

  /// 点击项目
  void onItemTap(CategoryItemProvider item) {
    showRecordDialog(context: context, item: item);
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
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCloseDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
              child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => InkWell(
                onTap: () {
                  onItemTap(items[index]);
                },
                child: RecordItemWidget(item: items[index])),
          ))
        ]),
      ),
    );
  }
}

/// 项目
class RecordItemWidget extends StatelessWidget {
  final CategoryItemProvider item;

  const RecordItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey.shade300),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconData(int.parse(item.icon), fontFamily: Icons.abc.fontFamily),
              size: 28),
          const SizedBox(height: 4),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 选择日期和输入内容弹窗
class RecordPopup extends StatefulWidget {
  /// 分类名称
  final String categoryName;

  /// 分类id
  final int categoryId;

  /// 传入此参数代表是修改记录
  final RecordItem? record;
  /// 完成时回调
  final Function? onDone;
  const RecordPopup(
      {super.key,
      required this.categoryName,
      required this.categoryId,
      this.onDone,
      this.record});
  @override
  State<RecordPopup> createState() => _RecordPopupState();
}

class _RecordPopupState extends State<RecordPopup> {
  final _formKey = GlobalKey<FormState>();

  /// 备注
  String remark = '';

  /// 金额
  String amount = '';

  /// 日期
  DateTime date = DateTime.now();

  /// 取消
  void onCancel() {
    Navigator.pop(context);
  }
  Function? onDone;

  Future<void> onSelectDate() async {
    var respond = await showYearMonthPicker(
        context: context, value: date, fields: const ['year', 'month', 'day']);
    if (respond != null) {
      setState(() {
        date = respond;
      });
    }
  }

  /// 确认
  void onConfirm() async {
    RecordItem item = RecordItem(
      remark: remark,
      amount: double.parse(amount),
      billDate: date,
      categoryId: widget.categoryId,
      icon: '', // Provide a valid icon value
      id: widget.record?.id ?? 0, // Provide a valid id value
      name: widget.categoryName, // Provide a valid name value
      categoryType: CategoryType.expense, // Provide a valid categoryType value
    );
    if (widget.record != null) {
      /// 编辑模式
      await DBManager().updateRecord(item);
    } else {
      print('新增模式');
      await DBManager().insertRecord(item);
    }
    widget.onDone?.call();
    onDone?.call();
    /// 关闭两个弹窗
    onCancel();
    // widget.onDone?.call();
    onCancel();
  }

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      setState(() {
        remark = widget.record!.remark;
        amount = widget.record!.amount.toString();
        date = widget.record!.billDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      onDone = () {
        ref.read(refreshHomeProvider.notifier).update();
      };
      return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: onSelectDate,
                    child: Row(spacing: 2, children: [
                      Text(
                        formatDate(date),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ]),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: TextFormField(
                  initialValue: amount,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  textAlign: TextAlign.center,
                  focusNode: FocusNode(),
                  onChanged: (value) => amount = value,
                  decoration: const InputDecoration(
                    hintText: '请输入成本',
                  ),
                ),
              ),
              TextFormField(
                initialValue: remark,
                onChanged: (value) => remark = value,
                decoration: const InputDecoration(
                  hintText: '项目描述:',
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 20,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: onConfirm,
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ));
    });
  }
}

/// 显示记录弹窗
Future showRecordDialog(
    {required BuildContext context,
    RecordItem? record,
    Function? onDone,
    CategoryItemProvider? item}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: RecordPopup(
            categoryName: item?.name ?? record?.name ?? '',
            categoryId: item?.id ?? record?.categoryId ?? 0,
            onDone: onDone,
            record: record),
      );
    },
  );
}
