import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_app/api/login.dart';
import 'package:my_app/model/user.dart';
import '../views/model/profile.dart';
import '../views/api/index.dart';

const env = 'prod';

class Global {
  static GetStorage box = GetStorage();
  static Profile profile = Profile();
  // 网络缓存对象
  // static NetCache netCache = NetCache();
  // 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    $api.interceptors.add(CustomInterceptors());
    var profileStr = box.read("profile");
    if (profileStr != null) {
      try {
        profile = Profile.fromJson(jsonDecode(profileStr));
      } catch (e) {
        print(e);
      }
    }else{
      // 默认主题索引为0，代表蓝色
      profile= Profile()..theme=0;
    }
    // 如果没有缓存策略，设置默认缓存策略
    // profile.cache = profile.cache ?? CacheConfig()
    //   ..enable = true
    //   ..maxAge = 3600
    //   ..maxCount = 100;

    //初始化网络请求相关配置
    // Git.init();
    await GetStorage.init();
  }

  // 持久化Profile信息
  static saveProfile() =>
      box.write("profile", jsonEncode(profile.toJson()));
  static removeProfile() => box.remove("profile");
}
/// 用户登录
Future<AuthUser> handleLogin(String name, String pw, [String? code]) async {
  final response = await (code == null ? loginByPw(name, pw) : loginByCode(name, pw, code));
  if (response.data!.isNotEmpty) {
    Global.profile.token = response.data!["access_token"];
    Global.profile.refToken = response.data!["refresh_token"];
    Global.profile.lastLogin = DateTime.now().toString();
    // 提前10分钟刷新token
    final exp = (response.data!["expires_in"] as int) - 600;
    Global.profile.expTime = DateTime.now().millisecondsSinceEpoch + exp * 1000;
    return refUserInfo();
  } else {
    throw response;
  }
}
/// 刷新用户信息
Future<AuthUser> refUserInfo() async {
  final value = await getUserExtend();
  final response = value.data!['data'] as Map<String, dynamic>;
  Global.profile.user = AuthUser.fromJson(response);
  Global.saveProfile();
  return Global.profile.user!;
}
/// 退出登录
Future<void> handleLogout() async {
  Global.profile.token = null;
  Global.profile.refToken = null;
  Global.profile.lastLogin = null;
  // 提前10分钟刷新token
  Global.profile.expTime = 1;
  Global.profile.user = null;
  Global.removeProfile();
}