import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:isar/isar.dart';
import '../utils/log_util.dart';

import '../models/system/system_config.dart';
import 'database_service.dart';

/// 应用配置服务
class AppConfigService {
  late Isar _isar;
  bool _initialized = false;

  /// 当前主题模式
  ThemeMode themeMode = ThemeMode.system;

  /// 用户认证信息
  String? _authToken;
  DateTime? _tokenExpireTime;
  String? _currentUsername;

  /// 初始化服务
  Future<void> init(Isar db) async {
    LogUtil.info('AppConfigService', '🔧 正在初始化应用配置服务...');
    _isar = db;
    _initialized = true;

    // 并行加载多个配置项以提高性能
    await Future.wait([
      _loadThemeMode(),
      _loadAuthInfo(),
    ]);

    LogUtil.info('AppConfigService', '✅ 应用配置服务初始化完成');
  }

  /// 检查服务是否已初始化
  bool get isInitialized => _initialized;

  // -------------------
  // 主题管理
  // -------------------

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final modeStr = _themeModeToString(mode);
      await setString(ConfigTypeEnum.THEME_MODE, modeStr);
      themeMode = mode;
      LogUtil.info('AppConfigService', '🎨 主题模式已更新: ${mode.name}');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 设置主题模式失败', e);
      rethrow;
    }
  }

  /// 加载主题模式
  Future<void> _loadThemeMode() async {
    try {
      final themeResult = await getString(ConfigTypeEnum.THEME_MODE);
      themeResult.fold(
        (themeStr) {
          themeMode = _parseThemeMode(themeStr);
          LogUtil.info('AppConfigService', '🎨 主题模式已加载: ${themeMode.name}');
        },
        (exception) {
          LogUtil.warning('AppConfigService', '⚠️ 加载主题模式失败，使用默认值', exception);
          themeMode = ThemeMode.system;
        },
      );
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 加载主题模式时出错', e);
      themeMode = ThemeMode.system;
    }
  }

  // -------------------
  // 登录状态管理
  // -------------------

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    LogUtil.debug('AppConfigService', '🔐 检查登录状态');
    try {
      final result = await getString(ConfigTypeEnum.LOGIN_STATUS);
      return result.fold(
        (content) => content == "true",
        (exception) {
          LogUtil.warning('AppConfigService', '⚠️ 获取登录状态失败', exception);
          return false;
        },
      );
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 检查登录状态时出错', e);
      return false;
    }
  }

  /// 设置登录状态
  Future<void> setLoggedIn(bool loggedIn) async {
    try {
      await setString(ConfigTypeEnum.LOGIN_STATUS, loggedIn.toString());
      LogUtil.info('AppConfigService', '🔐 登录状态已更新: ${loggedIn ? '已登录' : '未登录'}');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 设置登录状态失败', e);
      rethrow;
    }
  }

  // -------------------
  // 认证信息管理
  // -------------------

  /// 获取认证令牌
  String? get authToken => _authToken;

  /// 获取令牌过期时间
  DateTime? get tokenExpireTime => _tokenExpireTime;

  /// 获取当前用户名
  String? get currentUsername => _currentUsername;

  /// 保存认证信息
  Future<void> saveAuthInfo(String token, DateTime expireTime, String username) async {
    try {
      await Future.wait([
        setString(ConfigTypeEnum.TOKEN, token),
        setString(ConfigTypeEnum.TOKEN_EXPIRE_TIME, expireTime.millisecondsSinceEpoch.toString()),
        setString(ConfigTypeEnum.USER_NAME, username),
        setLoggedIn(true),
      ]);

      _authToken = token;
      _tokenExpireTime = expireTime;
      _currentUsername = username;

      LogUtil.info('AppConfigService', '🔑 认证信息已保存: 用户名=$username');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 保存认证信息失败', e);
      rethrow;
    }
  }

  /// 加载认证信息
  Future<void> _loadAuthInfo() async {
    try {
      final results = await Future.wait([
        getString(ConfigTypeEnum.TOKEN),
        getString(ConfigTypeEnum.TOKEN_EXPIRE_TIME),
        getString(ConfigTypeEnum.USER_NAME),
      ], eagerError: false);

      // 处理令牌
      results[0].fold(
        (token) => _authToken = token,
        (exception) => LogUtil.debug('AppConfigService', '未找到保存的令牌'),
      );

      // 处理过期时间
      results[1].fold(
        (expireTimeStr) {
          try {
            final milliseconds = int.parse(expireTimeStr);
            _tokenExpireTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          } catch (e) {
            LogUtil.warning('AppConfigService', '解析令牌过期时间失败', e);
          }
        },
        (exception) => LogUtil.debug('AppConfigService', '未找到保存的令牌过期时间'),
      );

      // 处理用户名
      results[2].fold(
        (username) => _currentUsername = username,
        (exception) => LogUtil.debug('AppConfigService', '未找到保存的用户名'),
      );

      if (_authToken != null && _currentUsername != null) {
        LogUtil.info('AppConfigService', '👤 认证信息已加载: 用户名=$_currentUsername');
      }
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 加载认证信息时出错', e);
    }
  }

  /// 清除认证信息
  Future<void> clearAuthInfo() async {
    try {
      await Future.wait([
        remove(ConfigTypeEnum.TOKEN),
        remove(ConfigTypeEnum.TOKEN_EXPIRE_TIME),
        remove(ConfigTypeEnum.USER_NAME),
        setLoggedIn(false),
      ], eagerError: false);

      _authToken = null;
      _tokenExpireTime = null;
      _currentUsername = null;

      LogUtil.info('AppConfigService', '🧹 认证信息已清除');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 清除认证信息失败', e);
      rethrow;
    }
  }

  /// 检查令牌是否有效
  bool isTokenValid() {
    if (_authToken == null || _tokenExpireTime == null) {
      return false;
    }

    return DateTime.now().isBefore(_tokenExpireTime!);
  }

  // -------------------
  // 首次启动标记
  // -------------------

  /// 检查是否为首次启动
// 修改 isFirstLaunch 方法
  /// 检查是否为首次启动
  Future<bool> isFirstLaunch() async {
    LogUtil.debug('AppConfigService', '🆕 检查是否为首次启动');
    try {
      final result = await getString(ConfigTypeEnum.FIRST_START_TIME);
      return result.fold(
            (content) => false, // 如果存在时间戳，则不是首次启动
            (exception) {
          LogUtil.warning('AppConfigService', '⚠️ 检查首次启动状态失败', exception);
          return true;
        },
      );
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 检查首次启动状态时出错', e);
      return true;
    }
  }

  /// 设置首次启动时间
  Future<void> setFirstLaunchTime() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      await setString(ConfigTypeEnum.FIRST_START_TIME, currentTime);
      LogUtil.info('AppConfigService', '🚀 首次启动时间已记录: $currentTime');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 设置首次启动时间失败', e);
      rethrow;
    }
  }

  // -------------------
  // 通用配置操作
  // -------------------

  /// 获取字符串配置
  Future<Result<String>> getString(ConfigTypeEnum key) async {
    try {
      final config = await _getConfig(key);
      if (config != null) {
        LogUtil.debug('AppConfigService', '📄 获取配置: ${key.name} = ${config.content}');
        return Success(config.content);
      } else {
        LogUtil.debug('AppConfigService', '📄 配置项不存在: ${key.name}');
        return Failure(Exception('配置项不存在: ${key.name}'));
      }
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 获取配置失败: ${key.name}', e);
      return Failure(Exception('获取配置失败: ${key.name}'));
    }
  }

  /// 设置指定配置项的值
  Future<void> setString(ConfigTypeEnum key, String value) async {
    try {
      final config = SystemConfig()
        ..configType = key
        ..content = value;

      await _isar.writeTxn(() => _isar.systemConfigs.put(config));
      LogUtil.info('AppConfigService', '💾 保存配置: ${key.name} = $value');
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 保存配置失败: ${key.name}', e);
      rethrow;
    }
  }

  /// 删除某个配置项
  Future<void> remove(ConfigTypeEnum key) async {
    try {
      final config = await _getConfig(key);
      if (config != null) {
        await _isar.writeTxn(() => _isar.systemConfigs.delete(config.id));
        LogUtil.info('AppConfigService', '🗑️ 删除配置: ${key.name}');
      } else {
        LogUtil.debug('AppConfigService', '🗑️ 配置不存在，无需删除: ${key.name}');
      }
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 删除配置失败: ${key.name}', e);
      rethrow;
    }
  }

  // -------------------
  // 内部方法
  // -------------------

  /// 获取配置项
  Future<SystemConfig?> _getConfig(ConfigTypeEnum key) async {
    try {
      return await _isar.systemConfigs
          .filter()
          .configTypeEqualTo(key)
          .findFirst();
    } catch (e) {
      LogUtil.error('AppConfigService', '❌ 查询配置失败: ${key.name}', e);
      rethrow;
    }
  }

  /// 解析主题模式
  ThemeMode _parseThemeMode(String? modeStr) {
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  /// 将主题模式转换为字符串
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}

/// 结果类型定义
abstract class Result<T> {}

class Success<T> implements Result<T> {
  final T value;
  Success(this.value);
}

class Failure<T> implements Result<T> {
  final Exception exception;
  Failure(this.exception);
}

extension ResultExtension<T> on Result<T> {
  R fold<R>(R Function(T) onSuccess, R Function(Exception) onFailure) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else {
      return onFailure((this as Failure<T>).exception);
    }
  }
}

/// Riverpod provider for AppConfigService
final appConfigServiceProvider = FutureProvider<AppConfigService>((ref) async {
  LogUtil.info('AppConfigServiceProvider', '🔄 正在创建 AppConfigService...');
  try {
    final databaseService = await ref.watch(databaseServiceAsyncProvider.future);
    final appConfigService = AppConfigService();
    await appConfigService.init(databaseService.db);
    LogUtil.info('AppConfigServiceProvider', '✅ AppConfigService 创建完成');
    return appConfigService;
  } catch (e) {
    LogUtil.error('AppConfigServiceProvider', '❌ AppConfigService 创建失败', e);
    rethrow;
  }
});
