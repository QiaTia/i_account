import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/views/mine/widget/change_language.dart';
import 'package:i_account/views/mine/widget/import_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:i_account/common/show_modal/show_modal_bottom_detail.dart';
import 'package:i_account/store/application.dart';
import 'package:i_account/views/mine/widget/change_theme.dart';
import 'package:i_account/common/widget/base.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(context, ref) {
    final appProvider = ref.read(currentApplicationProvider.notifier);
    /// 操作内容
    final list = [
      _SettingItem(
        iconData: Icons.account_circle_outlined,
        title: 'appTitle'.tr()),
      _SettingItem(
        iconData: Icons.file_copy_outlined,
        label: 'mine.data_import_hint'.tr(),
        action: () {
          importSheet(context);
        },
        title: 'mine.data_import'.tr()),
      // _SettingItem(
      //   icon: 'assets/icon/ic_about.png',
      //   title: 'mine.changePassword'.tr(),
      //   action: () {
      //     nav.pushNamed('/2048');
      //   }
      // ),
      _SettingItem(
        iconData: Icons.add_photo_alternate_outlined,
        title: 'mine.theme_settings'.tr(),
        action: () {
          showModalBottomDetail(
            context: context,
            child: const ChangeThemeWidget(),
            isDark: appProvider.isDarkMode,
          );
        },
      ),
      _SettingItem(
        iconData: Icons.language_outlined,
        title: 'mine.language_settings'.tr(),
        action: () {
          showModalBottomDetail(
            context: context,
            child: const ChangeLanguage(),
            isDark: appProvider.isDarkMode,
          );
          }),
      // _SettingItem(
      //     icon: 'assets/icon/ic_about.png',
      //     title: 'mine.privacy'.tr(),
      //     action: () {
      //       toWebView('https://h5.bwcj.com/bwgf/doc/privacy');
      //     }),
      _SettingItem(
        // icon: 'assets/icon/ic_about.png',
        iconData: Icons.info_outlined,
        title: 'mine.about_us'.tr(),
        action: () async {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          showAboutDialog(
            context: context,
            applicationName: packageInfo.appName,
            applicationVersion: packageInfo.version,
            // applicationIcon: const Icon(Icons.account_balance_wallet),
            applicationLegalese: 'Copyright © 2025 Tia',
          );
        },
        path: '/sys/about'),
      // _SettingItem(
      //     icon: 'assets/icon/ic_about.png',
      //     title: 'mine.other_settings'.tr(),
      //     path: '/sys/setting'),
    ];
    return Scaffold(
      // backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('settings', style: TextStyle(fontWeight: FontWeight.w500)).tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48),
        child: ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (_, index) {
            // 退出登录, 最后一项
            if (index == list.length) {
              return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: InkWell(
                      onTap: () => exitApp(context),
                      child: ListItem(
                        iconData: Icons.exit_to_app_outlined,
                        name: 'mine.exitApp'.tr(),
                        showArrow: true,
                        borderRadius: 8)));
            }
            final item = list[index];
            return InkWell(
                onTap: () {
                  if (item.action != null) {
                    item.action!();
                  } else if (item.path != null) {
                    // Get.toNamed(item.path!);
                  } else {
                    print(item.title);
                  }
                },
                child: ListItem(
                    name: item.title,
                    showArrow: item.action != null,
                    // icon: item.icon,
                    label: item.label,
                    iconData: item.iconData,
                    right: item.content));
          },
        ),
      ));
  }
}

class _SettingItem {
  // /// 图标地址
  // final String icon;

  /// 标题
  final String title;

  /// 跳转页面
  final String? path;

  /// 内容
  final String? content;

  /// 下方描述内容
  final String? label;

  /// 跳转页面
  final Function? action;

  /// IconWidget
  final IconData? iconData;

  _SettingItem({
    // this.icon = '',
    required this.title,
    this.path,
    this.content,
    this.label,
    this.iconData,
    this.action
  });
}


/// 退出APP
void exitApp(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  SystemNavigator.pop();
}
