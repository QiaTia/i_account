import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Update {
  String? packageName;
  final dio = Dio();

  /// 检查是否有新版本
  checkoutUpdate() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    packageName = info.packageName;
    var result = await dio.get('/checkout', data: info.data);
    if (result.data != null) {
      // ..
    }
  }

  /// 去市场更新 仅限安卓 | IOS
  onUpdate() async {
    var url = Platform.isIOS
        ? "https://apps.apple.com/cn/app/id6449995187"
        : "market://details?id=$packageName";
    return await launchUrl(Uri.parse(url));
  }

  /// 下载安装包
  onDown(String apkNetUrl) async {
    //手机中sd卡上 apk 下载存储路径
    String localPath = "";
    /// 默认超时
    const timeOut = Duration(seconds: 1200);
    //设置连接超时时间
    dio.options.connectTimeout = timeOut;
    //设置数据接收超时时间
    dio.options.receiveTimeout = timeOut;
    try {
      Response response = await dio.download(apkNetUrl, localPath,
          onReceiveProgress: (int count, int total) {
        // count 当前已下载文件大小
        // total 需要下载文件的总大小
      });
      if (response.statusCode == 200) {
        print('下载请求成功');
        //"安装";
      } else {
        //"下载失败重试";
      }
    } catch (e) {
      //"下载失败重试";
    }
  }

  /// 检查存储权限
  Future<bool> requestPermission() async {
    //获取当前的权限
    var status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  /// 检查安装外部应用权限 仅安卓
  Future<bool> requestInstallPackagesPermission() async {
    //获取当前的权限
    var status = await Permission.requestInstallPackages.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.requestInstallPackages.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
