import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:i_account/common/show_modal_bottom_detail/show_modal_bottom_detail.dart';
import 'package:i_account/store/application.dart';
import 'package:i_account/utils/modal.dart';
import 'package:i_account/views/home/home.dart';
import 'package:i_account/views/mine/widget/change_theme.dart';

// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/widget/base.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(context, ref) {
    // final ThemeMode themeMode = ref.watch(currentThemeModeProvider);
    // final MultipleThemeMode theme = ref.watch(currentThemeProvider);
    final nav = Navigator.of(context);
    final appProvider = ref.read(currentApplicationProvider.notifier);
    /// 操作内容
    final list = [
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mine.email'.tr(),
          content: '***@***.com'),
      // _SettingItem(
      //   icon: 'assets/icon/ic_about.png',
      //   title: 'mine.changePassword'.tr(),
      //   action: () {
      //     nav.pushNamed('/2048');
      //   }
      // ),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mine.theme_settings'.tr(),
          action: () {
            showModalBottomDetail(
              context: context,
              child: const ChangeThemeWidget(),
              isDark: appProvider.isDarkMode,
            );
            // themeModeProvider.setTheme(
            //     themeModeProvider.isDarkMode
            //         ? ThemeMode.light
            //         : ThemeMode.dark);
          },
        ),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mine.language_settings'.tr(),
          action: () async {
            // Get.toNamed('/sys/language');
            context.setLocale(context.locale.languageCode == 'zh'
                ? const Locale('en')
                : startLocale);
            await showModal(context, '完成设置，应用即将重载！');
            nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MyHomePage()), (_) => false);
          }),
      // _SettingItem(
      //     icon: 'assets/icon/ic_about.png',
      //     title: 'mine.privacy'.tr(),
      //     action: () {
      //       toWebView('https://h5.bwcj.com/bwgf/doc/privacy');
      //     }),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
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
          title: const Text('settings').tr(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48),
          child: ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (_, index) {
              // 退出登录, 最后一项
              if (index == list.length) {
                return Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: InkWell(
                        onTap: () {
                          // Get.defaultDialog(
                          //   onConfirm: () {
                          //     Get.offAllNamed('/');
                          //     // handleLogout();
                          //   },
                          //   radius: 4,
                          //   middleText: 'Confirm ?');
                        },
                        child: ListItem(
                            name: 'mine.exitAccount'.tr(), borderRadius: 8)));
              }
              var item = list[index];
              return InkWell(
                  onTap: () {
                    if (item.action != null) {
                      item.action!();
                    } else if (item.path != null) {
                      // Get.toNamed(item.path!);
                    } else {
                      print(item.title);
                      // Get.defaultDialog(
                      //   onConfirm: () {
                      //     Get.back();
                      //   },
                      //   radius: 4,
                      //   middleText: item.title);
                    }
                  },
                  child: ListItem(
                      name: item.title,
                      showArrow: item.action != null,
                      icon: item.icon,
                      right: item.content));
            },
          ),
        ));
  }
}

class _SettingItem {
  /// 图标地址
  final String icon;

  /// 标题
  final String title;

  /// 跳转页面
  final String? path;

  /// 内容
  final String? content;

  /// 跳转页面
  final Function? action;
  _SettingItem(
      {required this.icon,
      required this.title,
      this.path,
      this.content,
      this.action});
}
