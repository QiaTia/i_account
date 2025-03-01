import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../store/set.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('refresh');
    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('appTitle').tr(),
    );
    return Scaffold(
      appBar: appBar,
      body: Stack(children: [
        Transform.translate(
          offset: Offset(0, - (appBar.preferredSize.height)),
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
            child: const SizedBox(height: 300, width: double.infinity),
          ),
        ),
        Center(
          child: Column(
            children: <Widget>[
              const NavDataContainer(),
              const NavContainer(),
              const AnimatedText(),
              FilledButton(onPressed: () {
                // navigator.pushNamed("/word");
                Navigator.of(context).pushNamed("/word");
              }, child: const Text("mini.about").tr()),
            ],
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(clickCountProvider.notifier).increment();
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// 顶部导航栏
class NavContainer extends StatelessWidget {
  const NavContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final tabList = ['bill', 'detail', 'budget', 'home'];
    /// 菜单点击时
    void onMenuClick(String name) {
      switch(name) {
        case 'bill':
          // Navigator.of(context).pushNamed('/bill');
          break;
        case 'detail':
          // Navigator.of(context).pushNamed('/detail');
          break;
        case 'home':
          Navigator.of(context).pushNamed('/mine/settings');
          break;
        case 'budget':
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0
            )
          ]
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, 
              children: tabList.map((tex) => InkWell(
                onTap: () {
                  // 点击事件
                  onMenuClick(tex);
                }, 
                // style: OutlinedButton.styleFrom(side: BorderSide.none),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset('assets/images/ic_$tex.png', width: width),
                    const SizedBox(height: 4),
                    Text(tex).tr(),
                  ],
              ),
          )).toList()
        ),
      )
    );
  }
}

/// 顶部数据栏
class NavDataContainer extends StatefulWidget {
  const NavDataContainer({super.key});
  @override
  State<StatefulWidget> createState() => _NavDataContainer();
}

class _NavDataContainer extends State<NavDataContainer> {
  var selectedDate = DateTime.now();
  Future<void> _selectDate() async {
    _showYearMonthPicker(context);
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: selectedDate,
    //   firstDate: DateTime(1900),
    //   lastDate: DateTime(2100),
    // );
    // if (picked != null && picked != selectedDate) {
    //   setState(() => selectedDate = picked);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(children: [
          InkWell(
            onTap: _selectDate,
            child: Column(children: [
              const Text('home.income').tr(),
              const SizedBox(height: 4),
              const Text('￥0.00', style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
          const Padding(padding: EdgeInsets.only(left: 12)),
          const DecoratedBox(decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.black, // 边框颜色
                width: 1.0,         // 边框宽度
                style: BorderStyle.solid, // 边框样式（可选，默认为 solid）
              ),
          )),child: SizedBox(width: 0, height: 24 )),
        ]),
        Column(
          children: [
            const Text('home.income').tr(),
            const SizedBox(height: 4),
            const Text('￥0.00', style: TextStyle(fontWeight: FontWeight.bold)),
          ]
        ),
        Column(
          children: [
            const Text('home.spending').tr(),
            const SizedBox(height: 4),
            const Text('￥0.00', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
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
        )
      );
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
  const BottomBarItem({super.key, required this.label, required this.icon, this.onPressed});
  final String label;
  final Widget icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {

    return label.isEmpty ? const SizedBox() : OutlinedButton(
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
/// ③ 创建一个YearPicker组件，用于显示年份选择器
void _showYearMonthPicker(BuildContext context) {
  DateTime selectedDate = DateTime.now();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            // 年份选择
            Expanded(
              child: YearPicker(
                selectedDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
                onChanged: (date) {
                  selectedDate = date;
                  // 可在此处联动月份选择
                },
              ),
            ),
            // 月份选择
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (context, index) => TextButton(
                  onPressed: () {
                    final selectedYearMonth = DateTime(
                      selectedDate.year,
                      index + 1,
                    );
                    Navigator.pop(context, selectedYearMonth);
                  },
                  child: Text('${index + 1}月'),
                ),
                itemCount: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
