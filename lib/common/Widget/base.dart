import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import '../dashboard.dart';
// import 'package:my_app/common/global.dart';
// import 'package:get/get.dart';

/// 空内容
// ignore: constant_identifier_names
const Empty = SizedBox(width: 0, height: 0);

/// 菜单项目
class MenuListItem {
  /// 菜单图标
  final String icon;

  /// 菜单名称
  final String name;

  /// 页面路径
  final String? path;

  /// 菜单权限
  final String access;

  /// 菜单分组
  final int group;

  /// 预处理方法
  final Future<String?> Function()? prefix;
  MenuListItem(
      {required this.icon,
      required this.name,
      this.path,
      required this.access,
      this.group = 1,
      this.prefix});
}

/// 头像展示, 会自动取当前用户信息
// class Avatar extends StatefulWidget {
//   /// 内容大小, 会自动转自适应
//   final double? size;

//   /// 头像地址
//   final String? avatar;

//   /// 名称, 展示一个单词
//   final String? name;

//   /// 是否展示首字做头像
//   final bool showName;
//   const Avatar(
//       {super.key, this.size, this.showName = false, this.name, this.avatar});
//   @override
//   State<Avatar> createState() => _Avatar();
// }

// class _Avatar extends State<Avatar> {
//   // 初始化数据
//   double size = 64;
//   String avatar = Global.profile.user?.avatar ?? '';
//   String name = Global.profile.user?.name ?? '';
//   @override
//   void initState() {
//     // 父组件试试
//     if (widget.size != null) {
//       setState(() {
//         size = widget.size!;
//       });
//     }
//     if (widget.avatar != null) {
//       setState(() {
//         avatar = widget.avatar!;
//       });
//     }
//     if (widget.name != null) {
//       setState(() {
//         name = widget.name!;
//       });
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var content = widget.showName
//         ? Container(
//             alignment: Alignment.center,
//             color: Colors.blueAccent,
//             child: Text(
//               name.substring(0, 1),
//               style: TextStyle(fontSize: size.w / 1.6, color: Colors.white),
//             ))
//         : avatar.isNotEmpty
//             ? Image.network(avatar)
//             : SvgPicture.asset('assets/icon/logo.svg');
//     return ClipRRect(
//         borderRadius: BorderRadius.circular(size.w / 2),
//         child: SizedBox(width: size.w, height: size.w, child: content));
//   }
// }

/// DashboardItem
class DashboardItem extends StatelessWidget {
  const DashboardItem({super.key, required this.item});
  final MenuListItem item;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
          height: 71,
          width: 84,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // SvgPicture.asset(
            //   'assets/dashboard/ic_${item.icon}.svg',
            //   height: 30,
            //   width: 30,
            // ),
            const Padding(padding: EdgeInsets.only(top: 6)),
            Text(
              item.name,
              style: const TextStyle(
                  fontSize: 13, color: Color.fromRGBO(19, 32, 51, 1)),
            ),
          ])),
      onTap: () {
        if (item.prefix != null) {
          item.prefix!().then((value) {
            print(value ?? item.name);
          });
        } else {
          print(item.path);
          // Get.toNamed(item.path!);
        }
      },
    );
  }
}

/// 标题内容容器
class TitleContainer extends StatelessWidget {
  /// 标题
  final String name;

  /// 内容
  final Widget children;

  /// 标题右边
  final Widget? right;
  const TitleContainer(
      {super.key, required this.name, required this.children, this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 0, right: 12, bottom: 16),
      child: DecoratedBox(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.elliptical(10, 10))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, top: 19, bottom: 6),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      (right ?? const SizedBox(width: 0, height: 0)),
                    ])),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: children,
            )
          ])),
    );
  }
}

/// 列表项
class ListItem extends StatelessWidget {
  /// 标题
  final String name;

  /// 图标位置
  final String icon;

  /// 内容
  final Widget? body;

  /// 右侧内容
  final String? right;

  /// 是否显示分割线
  final bool showDivider;

  /// 是否展示右边箭头
  final bool showArrow;

  /// 圆角
  final double? borderRadius;

  /// IconData
  final IconData? iconData;

  /// 下方描述内容
  final String? label;

  const ListItem(
      {super.key,
      required this.name,
      this.icon = '',
      this.iconData,
      this.body,
      this.right,
      this.label,
      this.borderRadius = 0,
      this.showDivider = false,
      this.showArrow = false});

  Widget _buildContent(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(children: [
        // 注意：这里的 `icon` 应当是一个字符串
        icon.isNotEmpty || iconData != null
            ? Padding(
                padding: const EdgeInsets.only(right: 11),
                child: iconData != null
                    ? Icon(iconData, size: 16)
                    : Image.asset(icon, width: 16, height: 18))
            : Empty,
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          right != null
              ? Text(
                  right!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                )
              : Empty,
          showArrow
              ? const Icon(
                  Icons.chevron_right_outlined,
                  color: Colors.grey,
                  size: 17,
                )
              : Empty
        ]))
      ]),
      body ?? Empty,
      label != null
          ? Padding(
            padding: EdgeInsets.only(top: 2, right: 4), 
            child: Text(label!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey)))
          : Empty,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    /// 列
    final List<Widget> columnList = [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          child: _buildContent(context))
    ];
    // if (label != null) {
    //   columnList.add(Padding(
    //       padding: const EdgeInsets.only(right: 22, top: 0, bottom: 14),
    //       child: Text(label!,
    //           style: const TextStyle(
    //               fontSize: 12,
    //               color: Colors.grey,
    //               fontWeight: FontWeight.w400))));
    // }
    if (showDivider) {
      columnList.add(const Divider(height: 2, color: Colors.grey));
    }
    return DecoratedBox(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 0)),
        child: Column(children: columnList));
  }
}

/// 基于Get.bottomSheet封装好的ModalSheet
// Future<int> showModalSheet(List<Object> list) {
//   final completer = Completer<int>();
//   double height = 64 + (min(list.length, 6) * 44);
//   void onCancel() => completer.completeError('onCancel');
//   Get.bottomSheet(BottomSheet(
//       enableDrag: false,
//       clipBehavior: Clip.hardEdge,
//       onClosing: onCancel,
//       builder: (context) {
//          bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//         return SizedBox(height: height, child:Column(children: [
//           Expanded(
//               child: ListView.builder(
//             itemCount: list.length,
//             itemBuilder: (_, index) => InkWell(
//                 onTap: () {
//                   Get.back();
//                   completer.complete(index);
//                 },
//                 child: Container(
//                     height: 44,
//                     decoration: BoxDecoration(
//                         border: index == 0 ? null : Border(
//                             top: BorderSide(
//                                 color: Colors.grey.shade300, width: 0.5))),
//                     child: Center(child: Text(list[index].toString(), style: TextStyle(color: Theme.of(context).colorScheme.primary))))),
//           )),
//           Container(
//               decoration: BoxDecoration(
//                         border: Border(
//                             top: BorderSide(
//                                 color: isDarkMode ? Colors.white10 : Colors.grey.shade300, width: 10))),
//               child:
//                             TextButton(
//                   style: FilledButton.styleFrom(minimumSize: Size(375, 54)),
//                   onPressed: () {
//                     Get.back();
//                     onCancel();
//                   },
//                   child: Text('取消', style: Theme.of(context).textTheme.bodyLarge)))
//         ]));
//       }));
//   return completer.future;
// }

/// 缺省内容
class EmptyContent extends StatelessWidget {
  final String text;
  const EmptyContent({super.key, this.text = 'empty.data'});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset('assets/icon/ic_empty.svg', width: 130),
      const Padding(padding: EdgeInsets.only(top: 16)),
      Text(text.tr(), style: const TextStyle(fontSize: 14, color: Colors.grey))
    ]));
  }
}

/// AnimatedSwitcher的 child 切换时会对新child执行正向动画（forward），而对旧child执行反向动画（reverse）
class SlideTransitionX extends AnimatedWidget {
  SlideTransitionX({
    super.key,
    required Animation<double> position,
    this.transformHitTests = true,
    this.direction = AxisDirection.down,
    required this.child,
  }) : super(listenable: position) {
    switch (direction) {
      case AxisDirection.up:
        _tween = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
        break;
      case AxisDirection.right:
        _tween = Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));
        break;
      case AxisDirection.down:
        _tween = Tween(begin: const Offset(0, -1), end: const Offset(0, 0));
        break;
      case AxisDirection.left:
        _tween = Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
        break;
    }
  }

  final bool transformHitTests;

  final Widget child;

  final AxisDirection direction;

  late final Tween<Offset> _tween;

  @override
  Widget build(BuildContext context) {
    final position = listenable as Animation<double>;
    Offset offset = _tween.evaluate(position);
    if (position.status == AnimationStatus.reverse) {
      switch (direction) {
        case AxisDirection.up:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.right:
          offset = Offset(-offset.dx, offset.dy);
          break;
        case AxisDirection.down:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.left:
          offset = Offset(-offset.dx, offset.dy);
          break;
      }
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}
