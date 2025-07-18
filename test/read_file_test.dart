import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_account/utils/read_file.dart';


void main() {
  test('GB2312解码测试', () async {
    // 测试数据："中国" → 0xD6D0 0xB9FA
    final bytes = [0xD6, 0xD0, 0xB9, 0xFA];
    final str = await decodeBytes(Uint8List.fromList(bytes), 'gb2312');
    expect(str, equals('中国'));
  });
}