import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:i_account/store/set.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/Widget/base.dart';
// import 'package:my_app/common/dashboard.dart';
// import 'package:my_app/common/global.dart';
// import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// 操作内容
    final list = [
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.email'.tr(),
          content: '***@***.com'),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.phone'.tr(),
          content: '181****1234'),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.changePassword'.tr(),
          action: () {
            Navigator.of(context).pushNamed('/2048');
          }),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.language_settings'.tr(),
          action: () {
            // Get.toNamed('/sys/language');
            context.setLocale(context.locale.languageCode == 'zh'
                ? const Locale('en')
                : startLocale);
          }),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.privacy'.tr(),
          action: () {
            // toWebView('https://h5.bwcj.com/bwgf/doc/privacy');
          }),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.about_us'.tr(),
          path: '/sys/about'),
      _SettingItem(
          icon: 'assets/icon/ic_about.png',
          title: 'mini.other_settings'.tr(),
          path: '/sys/setting'),
    ];
    return Scaffold(
        // backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('settings').tr(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
                            name: 'mini.exitAccount'.tr(), borderRadius: 8)));
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
