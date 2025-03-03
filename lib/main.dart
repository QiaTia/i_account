import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_account/views/game/2048.dart';
import 'package:i_account/views/home/home.dart';
import 'package:i_account/views/piece.dart';
import './views/login/login.dart';
import './views/word.dart';
import './views/calc.dart';
import './views/music/player.dart';
import './views/mine/settings.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import './store/set.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(ProviderScope(
      child: EasyLocalization(
          supportedLocales: const [startLocale, Locale('en')],
          path:
              'assets/translations', // <-- change the path of the translation files
          startLocale: startLocale,
          fallbackLocale: const Locale('en'),
          child: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'appTitle'.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey, primary: Colors.blueGrey),
        hintColor: const Color(0xFF132033),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/word': (context) => const MyWord(),
        '/game': (context) => const GoGame(),
        '/calc': (context) => CalculatorScreen(),
        '/mine/settings': (context) => const SettingsPage(),
        '/music/player': (_) => MusicPlayerPage(),
        '/2048': (_) => My2048Game(),
      },
      home: const MyHomePage(),
    );
  }
}

// class CounterController extends GetxController {
//   var counter = 0.obs;

//   void increment() {
//     counter++;
//   }

//   void reset() {
//     counter.value = 0;
//   }
//   @override
//   void onInit() {
//     super.onInit();
//     print('onInit -> Controller开始初始化');

//     // 设置 Worker，比如监听 counter 的变化
//     ever(counter, (value) {
//       print('counter changed: $value');
//     });

//     // 如果需要请求一些不太大的数据，比如配置文件
//     // fetchInitialData();
//   }
//   @override
//   onReady() {
//     super.onReady();
//     print('onReady -> Controller初始化完成');
//   }
// }


// class MyHomePageTo extends StatefulWidget {
//   const MyHomePageTo({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final CounterController controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Colors.transparent,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: 
//               Obx(() => AnimatedSwitcher(
//               duration: const Duration(milliseconds: 200),
//               transitionBuilder: (Widget child, Animation<double> animation) {
//                   return SlideTransitionX(
//                     position: animation,
//                     direction: AxisDirection.up,
//                     child: child,
//                   );
//               },
//               child: Text(
//                 key: ValueKey<int>(controller.counter.value),
//                   controller.counter.value.toString(),
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//               )),
//             ),
//             const MyButton(),
//             const Padding(padding: EdgeInsets.only(top: 16)),
//             FilledButton(onPressed: () => Get.toNamed('/game'), child: const Text("Go to Word Page")),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         onPressed: controller.increment,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

// class MyButton extends StatelessWidget {
//   const MyButton({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final CounterController controller = Get.find();
//     return ElevatedButton(
//       key: ValueKey<int>(controller.counter.value),
//       onPressed: controller.reset,
//       child: const Text('Reset Counter'),
//     );
//   }
// }
