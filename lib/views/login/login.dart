import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isPasswordLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => SegmentedButton<bool>(segments: 
              const [
                ButtonSegment(value: true, label: Text('Password Login')),
                ButtonSegment(value: false, label: Text('SMS Login')),
              ], onSelectionChanged: (p0) {
                isPasswordLogin.value = p0.first;
              },
              selected: {isPasswordLogin.value})
            ),
            // Obx(() => ToggleButtons(
            //   isSelected: [isPasswordLogin.value, !isPasswordLogin.value],
            //   onPressed: (index) {
            //     isPasswordLogin.value = index == 0;
            //   },
            //   children: const [
            //      Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16.0),
            //       child: Text('Password Login'),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16.0),
            //       child: Text('SMS Login'),
            //     ),
            //   ],
            // )),
            const SizedBox(height: 20),
            Obx(() =>  isPasswordLogin.value ? PasswordLoginForm() : SMSLoginForm()),
          ],
        ),
      ),
    );
  }
}

class PasswordLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OptionTextField(placeholder: 'Username', leftTextList: ['+86', '+866', '+865'],),
        const OptionTextField(placeholder: 'Password'),

        const TextField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle password login
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}


class OptionTextField extends StatelessWidget {
  const OptionTextField({ super.key, this.value, this.placeholder, this.maxLength, this.leftText, this.leftTextList, this.height, this.leftPlaceholder, this.onLeftValue, this.onValue });
  /// 当前输入的值
  final String? value;
  /// 输入框输入内容
  final Function(String)? onValue;
  /// 占位内容
  final String? placeholder;
  /// 输入最大长度
  final int? maxLength;
  /// 左侧选中内容
  final String? leftText;
  /// 左侧选择内容占位
  final String? leftPlaceholder;
  /// 选择左侧选择内容
  final Function(String)? onLeftValue;
  /// 左侧选中内容列表
  final List<String>? leftTextList;
  /// 输入框高度
  final double? height;
  @override
  Widget build(BuildContext context) {

    return TextFormField(
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: placeholder ?? '请输入',
          prefixIcon: (leftTextList ?? []).isEmpty ? null : PopupMenuButton(
            onSelected: onLeftValue,
            itemBuilder: (context) => leftTextList!.map((val) => PopupMenuItem(
              value: val,
              child: Text(val),
            )).toList(),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(leftText ?? leftPlaceholder ?? 'Please Select')),
          ),
        
          prefixIconConstraints: BoxConstraints(maxHeight: height ?? 28)
        ),
        //校验用户名
        validator: (value) {
          return value!.trim().isNotEmpty ? null : "用户名不能为空";
        },
        onChanged: onValue,
      );
  }
}

class SMSLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Username'),
        ),
        const TextField(
          decoration: InputDecoration(labelText: 'Code'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle password login
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}