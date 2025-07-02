import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../models/system_config.dart';

class AppConfigService extends GetxService {
  late Isar _isar;

  /// 当前主题模式：支持响应式绑定
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// 初始化服务（由 main 中调用）
  Future<AppConfigService> init(Isar db) async {
    _isar = db;
    return this;
  }

  // -------------------
  // 登录状态管理
  // -------------------

  /// 是否已登录
  Future<bool> isLoggedIn() async {
    final config = await _getConfig(ConfigTypeEnum.LOGIN_STATUS);
    return config?.content == "true";
  }

  /// 设置登录状态
  Future<void> setLoginStatus(bool loggedIn) async {
    await _setString(ConfigTypeEnum.LOGIN_STATUS, loggedIn ? "true" : "false");
  }

  /// 清除登录相关信息
  Future<void> clearLoginInfo() async {
    await _remove(ConfigTypeEnum.LOGIN_STATUS);
    await _remove(ConfigTypeEnum.USER_NAME);
    await _remove(ConfigTypeEnum.TOKEN);
    await _remove(ConfigTypeEnum.TOKEN_CTEATE_TIME);
  }

  // -------------------
  // 通用存取接口
  // -------------------

  /// 读取指定配置项的字符串值
  Future<String?> getString(ConfigTypeEnum key) async {
    final config = await _getConfig(key);
    return config?.content;
  }

  /// 设置指定配置项的值
  Future<void> setString(ConfigTypeEnum key, String value) async {
    await _setString(key, value);
  }

  /// 删除某个配置项
  Future<void> remove(ConfigTypeEnum key) async {
    await _remove(key);
  }

  // -------------------
  // 首次启动标记
  // -------------------

  /// 是否为首次启动
  Future<bool> isFirstLaunch() async {
    final config = await _getConfig(ConfigTypeEnum.APP_NAME);
    return config?.content != "launched";
  }

  /// 设置已启动标记
  Future<void> markAppLaunched() async {
    await _setString(ConfigTypeEnum.APP_NAME, "launched");
  }

  // -------------------
  // 内部方法
  // -------------------

  Future<SystemConfig?> _getConfig(ConfigTypeEnum key) async {
    return await _isar.systemConfigs
        .filter()
        .configTypeEqualTo(key)
        .findFirst();
  }

  Future<void> _setString(ConfigTypeEnum key, String value) async {
    final config = SystemConfig()
      ..configType = key
      ..content = value;
    await _isar.writeTxn(() => _isar.systemConfigs.put(config));
  }

  Future<void> _remove(ConfigTypeEnum key) async {
    final config = await _getConfig(key);
    if (config != null) {
      await _isar.writeTxn(() => _isar.systemConfigs.delete(config.id));
    }
  }
}
