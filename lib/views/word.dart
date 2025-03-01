import 'package:flutter/material.dart';

class MyWord extends StatelessWidget {
  const MyWord({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
          title: const Text('Word of the Day'),
        ),
        body: AbandonPage(),
      );
  }
}

class AbandonPage extends StatelessWidget {
  final darkGreen = const Color(0xFF006400); // 自定义深绿色
  final darkGrey = Colors.grey[700];

  AbandonPage({super.key});   // 使用灰色的阴影

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.lightBlueAccent.withOpacity(0.1),
      // decoration: BoxDecoration(
      //   border: Border.all(color: darkGreen),
      // ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 标题区域
            Text(
              'abandon [əˈbændən] - 遗弃，放弃',
              style: TextStyle(fontSize: 24, color: darkGreen),
            ),
            const SizedBox(height: 20),

            // 词源解释区域
            Text(
              'ab- (离开、远离或去除)',
              style: TextStyle(fontSize: 18, color: darkGrey),
            ),
            Text(
              '-bannire (源自古法语的“ban”或“bannir”，意味着“命令”、“宣布”或“驱逐”)',
              style: TextStyle(fontSize: 18, color: darkGrey),
            ),
            const SizedBox(height: 20),

            // 图片带链接区域
            Image.network(
              'https://img.alicdn.com/imgextra/i2/O1CN01uvTkm71Zcyko06JcG_!!6000000003216-2-tps-1232-928.png',
              width: 300,
              height: 225,
            ),
            const SizedBox(height: 20),

            // 例句区域
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 18, color: darkGrey),
                children: [
                  const TextSpan(text: 'She decided to '),
                  TextSpan(
                    text: 'abandon',
                    style: TextStyle(color: darkGreen),
                  ),
                  const TextSpan(text: ' her old ways and start anew.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

