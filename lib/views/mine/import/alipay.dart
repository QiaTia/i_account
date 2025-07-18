import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:i_account/common/base/item_icon.dart';
import 'package:i_account/common/widget/base.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/utils/read_file.dart';
import 'package:i_account/store/set.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/views/home/Widget/record.dart';

class ImportAlipay extends ConsumerStatefulWidget {
  const ImportAlipay({super.key});
  @override
  ConsumerState<ImportAlipay> createState() => _ImportAlipayState();
}

class _ImportAlipayState extends ConsumerState<ImportAlipay> {
  late RefreshHome refreshHome;
  final DBManager $db = DBManager();

  /// 导入的记录
  List<RecordItem> list = [];

  /// 展示加载解析动画
  bool showLoading = false;

  /// 点击导入
  void onFileImport() {
    setState(() {
      showLoading = true;
    });
    importLocalFile2Parse().then((list) {
      if (list.isNotEmpty) {
        setState(() {
          this.list = list;
        });
      }

      /// 延迟1秒后关闭加载动画
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          showLoading = false;
        });
      });
    }).catchError((err) {
      setState(() {
        showLoading = false;
      });
    });
  }
  /// 确认导入到数据库
  void onConfirmImport() async {
    final nav = Navigator.of(context);
    final snack = ScaffoldMessenger.of(context);
    setState(() { showLoading = true; });
    for (var element in list) {
      await $db.insertRecord(element);
    }
    refreshHome.update();
    nav.pop();
    snack.showSnackBar(
      SnackBar(content: Text('mine.import.empty_success_hint'.tr())),
    );
  }

  /// 更换分类
  void onReplaceCategory(int index) async {
    final item = await showChangeCategoryDialog(context: context);
    if (item != null) {
      final it = list[index];
      final newItem = it.copyWith(
        categoryId: item.id!,
        categoryType: item.type,
        name: item.name,
        icon: item.icon,
      );
      setState(() {
        list[index] = newItem;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    refreshHome = ref.read(refreshHomeProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final appContent = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: showLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? EmptyPage(onImport: onFileImport)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          var it = list[index];
                          return Dismissible(
                            key: ValueKey(it),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.pink,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                list.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('mine.import.delete_record'.tr())),
                              );
                            },
                            child: ListTile(
                              onTap: () => onReplaceCategory(index),
                              leading: CircleItemIcon(name: it.icon),
                              title: Text(it.amount.toStringAsFixed(2)),
                              subtitle: Text(
                                it.remark,
                                overflow: TextOverflow.ellipsis,
                                style: appContent.textTheme.bodySmall!
                                    .copyWith(color: appContent.dividerColor),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('yyyy/MM/dd')
                                      .format(it.billDate)),
                                  Text(it.name)
                                ]),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appContent.colorScheme.primary,
                          foregroundColor: appContent.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onConfirmImport,
                        child: const Text('mine.import.confirm').tr(),
                      ),
                    )
                  ],
                ),
    );
  }
}

/// 数据为空的导入页面
class EmptyPage extends StatelessWidget {
  final VoidCallback? onImport;
  const EmptyPage({super.key, this.onImport});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 44,
        children: [
          EmptyContent(text: 'mine.import.empty_hint'.tr()),
          ElevatedButton(
            onPressed: () {
              if (onImport != null) onImport!();
            },
            child: const Text('mine.import.choose_file').tr(),
          ),
        ]);
  }
}
