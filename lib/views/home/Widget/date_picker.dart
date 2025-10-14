import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i_account/common/show_modal/show_modal_bottom_detail.dart';

/// 自定义动画打开DatePicker
Future<DateTime?> showYearMonthPicker(
    {required BuildContext context,
    DateTime? start,
    DateTime? end,
    List<String> fields = const ['year','month'],
    String title = "Select Date",
    DateTime? value}) async {
    return showModalBottomDetail<DateTime>(
      context: context,
      height: 400,
      child: CustomDatePicker(
        title: title,
        value: value,
        start: start,
        end: end,
        fields: fields,
      ));
  // return showGeneralDialog<DateTime>(
  //   context: context,
  //   pageBuilder: (context, animation, secondaryAnimation) {
  //     return CustomDatePicker(
  //       title: title,
  //       value: value,
  //       start: start,
  //       end: end,
  //       fields: fields,
  //     );
  //   },
  //   transitionBuilder: (context, animation, secondaryAnimation, child) {
  //     // 定义从下到上的动画
  //     var begin = const Offset(0.0, 1.0); // 起始位置（屏幕底部）
  //     var end = Offset.zero; // 结束位置（屏幕中央）
  //     var tween = Tween(begin: begin, end: end)
  //         .chain(CurveTween(curve: Curves.easeOut));

  //     return SlideTransition(
  //       position: animation.drive(tween),
  //       child: child,
  //     );
  //   },
  // );
}

/// 自定义日期选择器
class CustomDatePicker extends StatefulWidget {
  final String title;
  final DateTime? value;
  final DateTime? start;
  final DateTime? end;
  final List<String> fields;

  const CustomDatePicker({
    super.key,
    required this.title,
    this.value,
    this.start,
    this.end,
    this.fields = const ['year', 'month', 'day'],
  });

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late DateTime limitStart;
  late DateTime limitEnd;

  /// 关闭弹窗
  // void onCloseDialog() {
  //   Navigator.of(context).pop();
  // }

  /// 点击确认
  void onConfirm() {
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    Navigator.of(context).pop(selectedDate);
  }

  @override
  void initState() {
    super.initState();
    limitStart = widget.start ?? DateTime(2000, 1, 1);
    limitEnd = widget.end ?? DateTime.now();
    _selectedYear = widget.value?.year ?? limitStart.year;
    _selectedMonth = widget.value?.month ?? limitStart.month;
    _selectedDay = widget.value?.day ?? limitStart.day;

    _yearController = FixedExtentScrollController(
        initialItem: _selectedYear - limitStart.year);
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor.withAlpha(43))),
              ),
              child: Padding(padding: EdgeInsets.only(bottom: 12),
                child: Center(child: 
                  Text(widget.title,
                    style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)))),
            ),
            Expanded(
              child: Row(children: [
                if (widget.fields.contains('year'))
                  Expanded(
                    child: CupertinoPicker.builder(
                      itemExtent: 50.0,
                      scrollController: _yearController,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          _selectedYear = limitStart.year + index;
                        });
                      },
                      childCount: limitEnd.year - limitStart.year + 1,
                      itemBuilder: (context, index) {
                        return Center(
                            child: Text('${limitStart.year + index}'));
                      },
                    ),
                  ),
                if (widget.fields.contains('month'))
                  Expanded(
                    child: CupertinoPicker.builder(
                      itemExtent: 50.0,
                      scrollController: _monthController,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          _selectedMonth = index + 1;
                        });
                      },
                      childCount: 12,
                      itemBuilder: (context, index) {
                        return Center(
                            child:
                                Text((index + 1).toString().padLeft(2, '0')));
                      },
                    ),
                  ),
                if (widget.fields.contains('day'))
                  Expanded(
                    child: CupertinoPicker.builder(
                      itemExtent: 50.0,
                      scrollController: _dayController,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          _selectedDay = index + 1;
                        });
                      },
                      childCount:
                          DateTime(_selectedYear, _selectedMonth + 1, 0).day,
                      itemBuilder: (context, index) {
                        return Center(child: Text('${index + 1}'));
                      },
                    ),
                  ),
              ]),
            ),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onConfirm,
                child: const Text('modal.confirm').tr(),
            )),
          ],
        ),
      );
  }
}
