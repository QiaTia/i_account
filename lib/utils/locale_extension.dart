import 'dart:ui';

/// 为Locale类添加扩展属性
extension LocaleExtension on Locale {
  /// 获取本地化字符串表示
  String get tr {
    // 根据语言代码返回对应的本地化名称
    switch (languageCode) {
      case 'zh':
        if (countryCode == 'TW' || countryCode == 'HK') {
          return '繁體中文';
        }
        return '简体中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return '${languageCode}${countryCode != null ? ' ($countryCode)' : ''}';
    }
  }
}