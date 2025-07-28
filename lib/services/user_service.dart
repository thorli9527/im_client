// 文件路径: lib/services/user_service.dart

import 'package:fixnum/src/int64.dart';
import 'package:riverpod/riverpod.dart';
import 'package:im_client/models/system/login_response.dart';
import 'package:im_client/services/api_service.dart';
import 'package:im_client/services/app_config_service.dart';
import 'package:im_client/channel/stream_client.dart';
import 'package:im_client/config/app_config.dart';
import 'package:im_client/utils/log_util.dart';
import 'package:im_client/utils/time_util.dart';
import 'package:im_client/utils/id_utils.dart';
import 'package:im_client/models/generated/auth.pb.dart';
import 'package:im_client/models/generated/common.pbenum.dart';

import '../models/system/system_config.dart';

class UserService {
  final Ref _ref;

  UserService(this._ref);

  /// 使用Socket登录并保存认证信息
  Future<LoginResponse> loginWithSocket({
    required String username,
    required String password,
  }) async {
    try {
      LogUtil.info('UserService', '🔐 开始Socket登录: $username');

      // 获取 StreamClient
      final streamClient = _ref.read(streamClientProvider);

      // 确保连接已建立
      if (streamClient.status != ConnectionStatus.connected) {
        await streamClient.connect(AppConfig.socketHost, AppConfig.socketPort);
      }
      //

      // 创建登录请求消息
      final loginReq = LoginReqMsg.create()
        ..messageId = IdUtils.buildSnowflake() as Int64
        ..authType=AuthType.AUTH_TYPE_EMAIL
        ..password = password
        ..deviceType = DeviceType.DESKTOP;

      // 发送登录请求并等待响应
      final loginFuture = streamClient.waitForMessage<LoginRespMsg>(
        (msg) => msg.messageId == loginReq.messageId,
        timeout: Duration(seconds: 10),
      );

      // 发送登录请求
      streamClient.send(loginReq);

      // 等待登录响应
      final loginResp = await loginFuture;

      if (!loginResp.success) {
        throw Exception('登录失败');
      }

      // 创建LoginResponse对象
      final loginResponse = LoginResponse(
        token: loginResp.token,
        username: username,
        avatar: '', // 可根据实际需要从响应中获取
      );

      // 保存登录状态
      await _persistLoginState(loginResponse, username);

      LogUtil.info('UserService', '✅ Socket登录成功: $username');
      return loginResponse;
    } catch (e) {
      LogUtil.error('UserService', '❌ Socket登录失败', e);
      throw Exception('登录失败：$e');
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);
    final result = await appConfigService.getString(ConfigTypeEnum.LOGIN_STATUS);
    return result.fold(
      (status) => status == 'true',
      (exception) => false,
    );
  }

  /// 登出
  Future<void> logout() async {
    try {
      LogUtil.info('UserService', '🚪 开始登出');

      // 发送登出请求到服务器
      try {
        final logoutReq = LogoutReqMsg.create()
          ..messageId = IdUtils.buildSnowflake() as Int64;

        final streamClient = _ref.read(streamClientProvider);

        // 如果连接仍然有效，发送登出请求
        if (streamClient.status == ConnectionStatus.connected) {
          final logoutFuture = streamClient.waitForMessage<LogoutRespMsg>(
            (msg) => msg.messageId == logoutReq.messageId,
            timeout: Duration(seconds: 5),
          );

          streamClient.send(logoutReq);
          await logoutFuture; // 等待登出响应
        }
      } catch (e) {
        LogUtil.warning('UserService', '⚠️ 服务端登出请求失败', e);
      }

      // 获取服务
      final appConfigService = await _ref.read(appConfigServiceProvider.future);
      final streamClient = _ref.read(streamClientProvider);

      // 关闭Socket连接
      await streamClient.closeConnection();

      // 清除本地登录信息
      await _clearLoginState(appConfigService);

      LogUtil.info('UserService', '✅ 登出成功');
    } catch (e) {
      LogUtil.error('UserService', '❌ 登出失败', e);
      rethrow;
    }
  }

  /// 获取认证令牌
  Future<String?> getToken() async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);
    final result = await appConfigService.getString(ConfigTypeEnum.TOKEN);
    return result.fold(
      (token) => token,
      (exception) => null,
    );
  }
  /// 保存登录状态
  Future<void> _persistLoginState(
      LoginResponse login,
      String username,
      ) async {
    final appConfigService = await _ref.read(appConfigServiceProvider.future);

    // 执行所有设置操作，不关心返回值
    await Future.wait([
      appConfigService.setString(ConfigTypeEnum.LOGIN_STATUS, "true"),
      appConfigService.setString(ConfigTypeEnum.USER_NAME, username),
      appConfigService.setString(ConfigTypeEnum.TOKEN, login.token),
    ], eagerError: false);
  }


  /// 清除登录状态
  Future<void> _clearLoginState(AppConfigService appConfigService) async {
    final keys = [
      ConfigTypeEnum.LOGIN_STATUS,
      ConfigTypeEnum.USER_NAME,
      ConfigTypeEnum.TOKEN,
    ];

    for (final key in keys) {
      await appConfigService.remove(key);
    }
  }
}

// Riverpod Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref);
});
