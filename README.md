# i_account

一款使用flutter开发的记账软件。

## 主要技术栈
`sqflite` 提供本地sqlite数据库驱动

`flutter_riverpod` 提供状态管理，全局选择月份和主题配置

`shared_preferences` 提供本地存储, 持久化存储全局状态

`easy_localization` 提供多语言支持

`easy_refresh` 下拉刷新，分页加载

`flutter_svg` 提供svg图标展示

`fl_chart` 绘制图表

`file_picker` 文件选择

`charset` 文件内容解析，导入数据

## debug 运行

| platform-name | platform-value |
|--|--|
| Windows (desktop) | windows |
| Android (mobile) | android |
| MacOS (desktop) | macos |
| IOS (mobile) | ios |
| Edge (web) | edge |


```sh
flutter run $--target-platform
```

## build 构建包

Optimize package size where target platform!

```sh
flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
```
Optimize package size where confuse code !
```sh
flutter build apk --obfuscate --split-debug-info=debugInfo
```
Recommended
```sh
flutter build apk --obfuscate --split-debug-info=debugInfo --target-platform android-arm64 --split-per-abi
```