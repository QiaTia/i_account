import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/store/application.dart';
import 'package:i_account/utils/modal.dart';
import 'package:i_account/views/home/home.dart';

class ChangeLanguage extends ConsumerStatefulWidget {
  const ChangeLanguage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends ConsumerState {
  /// 选择语言
  Locale? selected;

  @override
  void initState() {
    super.initState();
    selected = ref.read(currentApplicationProvider).locale;
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final appProvider = ref.read(currentApplicationProvider.notifier);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        LabelRadio<Locale?>(
          list: [
            ('mine.follow'.tr(), null),
            ('简体中文', supportedLocales[0]),
            ('English', supportedLocales[1]),
            ('日本語', supportedLocales[2]),
          ],
          value: selected,
          label: 'mine.language_settings'.tr(),
          onChanged: (val) async {
            setState(() { selected = val; });
            appProvider.setLocale(val);
            print(Localizations.localeOf(context));
            context.setLocale(val ?? Localizations.localeOf(context));
            
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
    setState(() {
      _value = val as T;
    });
    if (widget.onChanged != null) widget.onChanged!(val as T);
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
