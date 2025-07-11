import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/model/record.dart';
import 'package:i_account/store/sql.dart';
import 'package:i_account/views/home/Widget/date_picker.dart';
import 'package:i_account/views/home/Widget/record.dart';
import 'package:i_account/views/details/details.dart';
import '../../store/set.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('appTitle').tr(),
      /// 淡出的状态栏渐变背景
      // flexibleSpace: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [
      //         Theme.of(context).primaryColor, // 起始颜色
      //         // 默认背景色
      //         Theme.of(context).colorScheme.onPrimary,
      //       ],
      //     ),
      //   ),
      // ),
    );
    var safeTopAreaHeight =
        appBar.preferredSize.height + MediaQuery.of(context).padding.top;
    /// 把顶部安全距离存储到统一变量里面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(safeTopAreaHeightProvider.notifier).update(safeTopAreaHeight);
    });
    
    DateTime? currentBackPressTime;
    /// 返回键退出
    bool closeOnConfirm() {
      DateTime now = DateTime.now();
      /// 两次间隔大于4秒, 退出请求无效
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 4)) {
        currentBackPressTime = now;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: const Text('confirmExitApp').tr()));
        return false;
      }
      /// 退出请求有效
      currentBackPressTime = null;
      return true;
    }
    void onPopInvokedWithResult(bool didPop, Object? result) {
      if (closeOnConfirm()) {
        // 系统级别导航栈 退出程序
        SystemNavigator.pop();
      }
    }
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: Scaffold(
          appBar: appBar,
          body: Stack(children: [
            /// 首先使状态栏透明，绘制一个渐变区域位移上去即可
            Transform.translate(
              offset: Offset(0, -(safeTopAreaHeight)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor, // 起始颜色
                      // 默认背景色
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: const SizedBox(height: 250, width: double.infinity),
              ),
            ),
            const Center(
              child: Column(
                children: <Widget>[
                  NavDataContainer(),
                  NavContainer(),
                  HomeList(),
                  // const AnimatedText(),
                  // FilledButton(
                  //   onPressed: () {
                  //     ref.read(clickCountProvider.notifier).increment();
                  //   },
                  //   child: const Text("mine.about").tr()),
                ],
              ),
            )
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showRecordPopup(context);
              // ref.read(clickCountProvider.notifier).increment();
            },
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ));
  }
}

/// 首页列表内容
class HomeList extends ConsumerWidget {
  const HomeList({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectDate = ref.watch(selectDateProvider);
    // final refHome = ref.watch(refreshHomeProvider);
    return Expanded(child: RecordList(selectDate: selectDate));
  }
}


/// 顶部导航栏
class NavContainer extends StatelessWidget {
  const NavContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final tabList = ['bill', 'detail', 'budget', 'settings'];
    final nav = Navigator.of(context);

    /// 菜单点击时
    void onMenuClick(String name) {
      switch (name) {
        case 'bill':
          nav.pushNamed('/$name');
          break;
        case 'detail':
          nav.pushNamed('/bill/chart');
          // nav.pushNamed('/details/detail');
          break;
        case 'settings':
          nav.pushNamed('/mine/settings');
          break;
        case 'budget':
          nav.pushNamed('/budget');
          // Navigator.of(context).pushNamed('/budget');
          break;
        default:
          print('Unknown menu item: $name');
      }
    }

    var width = MediaQuery.of(context).size.width / 375 * 39;

    return Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    spreadRadius: 0)
              ]),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tabList
                  .map((tex) => InkWell(
                        onTap: () {
                          // 点击事件
                          onMenuClick(tex);
                        },
                        // style: OutlinedButton.styleFrom(side: BorderSide.none),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/images/ic_$tex.png',
                                width: width),
                            const SizedBox(height: 4),
                            Text(tex).tr(),
                          ],
                        ),
                      ))
                  .toList()),
        ));
  }
}

class NavDataContainer extends StatefulWidget {
  const NavDataContainer({super.key});
  @override
  State<StatefulWidget> createState() => _NavDataContainer();
}

/// 顶部数据栏
class _NavDataContainer extends State<NavDataContainer> {
  List<String> navList = ['0.00', '0.00'];
  final DBManager dbManager = DBManager();
  /// 获取指定月份数据
  void getTotalData(DateTime select) async {
    var income = await dbManager.selectRecordTotal(CategoryType.income, select);
    var expense = await dbManager.selectRecordTotal(CategoryType.expense, select);
    setState(() {
      navList = [income, expense];
    });
  }
  @override
  Widget build(BuildContext context) {
    void onMenuClick(CategoryType type) {
      // 点击事件
      print('onMenuClick: $type');
      Navigator.of(context)
          .pushNamed('/details/details', arguments: type.state);
    }

    return Consumer(builder: (content, ref, child) {
      /// 选中日期
      final DateTime select = ref.watch(selectDateProvider);

      Future<void> onSelectDate() async {
        var respond =
            await showYearMonthPicker(context: context, value: select);
        if (respond != null) {
          ref.read(selectDateProvider.notifier).update(respond);
          getTotalData(respond);
        }
      }
      // 监听刷新状态
      ref.listen(refreshHomeProvider, (old, newProvider) {
        print('$old -> $newProvider');
        getTotalData(select);
      });
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(children: [
            InkWell(
              onTap: onSelectDate,
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Text(select.year.toString()),
                      const SizedBox(width: 8)
                    ]),
                    Row(
                      children: [
                        Text(select.month.toString().padLeft(2, '0'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Icon(Icons.arrow_drop_down, size: 14),
                      ],
                    )
                  ]),
            ),
            const Padding(padding: EdgeInsets.only(left: 12)),
            const DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                  right: BorderSide(
                    color: Colors.black, // 边框颜色
                    width: 1.0, // 边框宽度
                    style: BorderStyle.solid, // 边框样式（可选，默认为 solid）
                  ),
                )),
                child: SizedBox(width: 0, height: 24)),
          ]),
          InkWell(
            onTap: () {
              onMenuClick(CategoryType.income);
            },
            child: Column(
              spacing: 4,
              children: [
                const Text('income').tr(),
                Text('￥${navList[0]}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
          InkWell(
              onTap: () {
                onMenuClick(CategoryType.expense);
              },
              child: Column(
                spacing: 4,
                children: [
                  const Text('expense').tr(),
                  Text('￥${navList[1]}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ))
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getTotalData(DateTime.now());
  }
}

// ④ 创建一个AnimatedText组件，用于显示动画效果的文本
class AnimatedText extends StatelessWidget {
  const AnimatedText({super.key});

  @override
  Widget build(BuildContext context) {
    /// 颗粒画, 减少重绘
    return Consumer(builder: (content, ref, child) {
      final int count = ref.watch(clickCountProvider);
      return Padding(
          padding: const EdgeInsets.only(bottom: 26, top: 14),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransitionX(
                position: animation,
                direction: AxisDirection.up,
                child: child,
              );
            },
            child: Text(
              key: ValueKey<int>(count),
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ));
    });
  }
}

// AnimatedSwitcher的 child 切换时会对新child执行正向动画（forward），而对旧child执行反向动画（reverse）
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

class BottomBarItem extends StatelessWidget {
  const BottomBarItem(
      {super.key, required this.label, required this.icon, this.onPressed});
  final String label;
  final Widget icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return label.isEmpty
        ? const SizedBox()
        : OutlinedButton(
            onPressed: () {
              if (onPressed != null) onPressed!();
              // ⑤ 获取Provider的通知器修改状态值(自增)
              // ref.read(clickCountProvider.notifier).ref.;
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide.none,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                icon,
                Text(label, style: const TextStyle(fontSize: 12)).tr(),
              ],
            ),
          );
  }
}
