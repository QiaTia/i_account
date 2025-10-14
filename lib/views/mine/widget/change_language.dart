import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/application.dart';
import 'package:i_account/utils/modal.dart';
import 'package:i_account/utils/locale_extension.dart'; // 添加导入
import 'package:i_account/views/home/home.dart';

class ChangeLanguage extends ConsumerStatefulWidget {
  const ChangeLanguage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends ConsumerState {
  /// 选择语言
  late int selected;

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentApplicationProvider).locale;
    if (current != null) {
      selected = supportedLocales.indexWhere((element) => element.languageCode == current.languageCode);
    } else {
      selected = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final appProvider = ref.read(currentApplicationProvider.notifier);
    List<(String, int)> optionsList = [
      ('mine.follow'.tr(), -1),
    ];
    int index = 0;
    optionsList.addAll(
      supportedLocales.map((item) => (item.tr, index++))
    );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        LabelRadio<int>(
          list: optionsList,
          value: selected,
          label: 'mine.language_settings'.tr(),
          onChanged: (val) async {
            setState(() { selected = val; });
            Locale local = val != -1 ? supportedLocales[val] :  Locale.fromSubtags(languageCode: context.deviceLocale.languageCode, scriptCode: context.deviceLocale.scriptCode);
            appProvider.setLocale(val != -1 ? local : null);
            context.setLocale(local);
            await Future.delayed(const Duration(milliseconds: 100));
            // 刷新应用程序配置
            await showModal(context, 'mine.language_confirm_hint'.tr());
            nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MyHomePage()), (_) => false);
          },
        )
      ],
    );
  }
}

/// 单选框
class LabelRadio<T> extends StatefulWidget {
  /// 默认选择项目
  final T value;

  /// 选项列表
  final List<(String, T)> list;

  /// 选中回调
  final Function(T val)? onChanged;

  /// 描述说明
  final String label;

  const LabelRadio(
      {super.key,
      required this.value,
      required this.list,
      this.onChanged,
      required this.label});
  @override
  State<LabelRadio> createState() => _LabelRadio<T>();
}

class _LabelRadio<T> extends State<LabelRadio<T>> {
  late T _value;
  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  /// 选中回调
  void onSelect(T? val) {
    print(val);
    if (val == null) return;
    setState(() {
      _value = val;
    });
    if (widget.onChanged != null) widget.onChanged!(val);
  }

  @override
  Widget build(BuildContext context) {
    /// 单选框 Label
    var children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      )
    ];

    /// 单选框列表
    children.addAll(widget.list
        .map(
          (item) => RadioListTile<T>(
            title: Text(item.$1),
            value: item.$2,
            groupValue: _value,
            onChanged: onSelect,
          ),
        )
        .toList());
    return Column(children: children);
  }
}