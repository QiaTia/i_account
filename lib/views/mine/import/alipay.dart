import 'package:flutter/material.dart';
import 'package:i_account/common/widget/base.dart';
import 'package:i_account/utils/read_file.dart';
import 'package:i_account/store/set.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportAlipay extends ConsumerStatefulWidget {
  const ImportAlipay({super.key});
  @override
  ConsumerState<ImportAlipay> createState() => _ImportAlipayState();
}

class _ImportAlipayState extends ConsumerState<ImportAlipay> {
  late RefreshHome refreshHome;
  /// 点击导入
  void onFileImport() {
    onFileImportRecord().then((_)  {
      refreshHome.update();
    });
  }

  @override
  void initState() {
    super.initState();
    refreshHome = ref.read(refreshHomeProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyPage(onImport: onFileImport),
    );
  }
}

class EmptyPage extends StatelessWidget {
  // final ValueChanged<void>? onImport;
  final VoidCallback? onImport;
  const EmptyPage({ super.key, this.onImport });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 44,
      children: [
        const EmptyContent(text: '点击下方按钮选择需要导入的账单文件吧？',),
        ElevatedButton(
          onPressed: () {
            if (onImport != null) onImport!();
          },
          child: const Text('选择文件'),
        ),
    ]);
  }
}