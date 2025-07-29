// 文件路径: lib/services/user_service.dart

import 'dart:io';
import 'package:fixnum/src/int64.dart';
import 'package:riverpod/riverpod.dart';
import 'package:im_client/models/system/login_response.dart';
import 'package:im_client/services/api_service.dart';
import 'package:im_client/services/app_config_service.dart';
import 'package:im_client/services/message/ack_message_service.dart'; // 添加导入
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

      // 获取 StreamClient 和 AckMessageService
      final streamClient = _ref.read(streamClientProvider);
      final ackService = _ref.read(ackMessageServiceProvider);

      // 确保连接已建立
      if (streamClient.status != ConnectionStatus.connected) {
        await streamClient.connect(AppConfig.socketHost, AppConfig.socketPort);
      }

      // 创建登录请求消息，使用雪花ID
      final messageId = IdUtils.buildSnowflake();
      final loginReq = LoginReqMsg.create()
        ..messageId = Int64(messageId)
        ..authType = AuthType.AUTH_TYPE_EMAIL
        ..authContent = username
        ..password = password
        ..deviceType = DeviceType.DESKTOP;

      // 将消息添加到ACK服务中
      await ackService.addPendingMessage(
        messageId: messageId,
        messageType: ByteMessageType.LoginReqMsgType.value,
        originalData: loginReq.writeToBuffer(),
      );

      // 等待登录响应
      final loginFuture = streamClient.waitForMessage<LoginRespMsg>(
            (msg) => msg.messageId == Int64(messageId),
        timeout: Duration(seconds: 15),
      );

      // 等待登录响应
      final loginResp = await loginFuture;

      // 标记消息为已确认（冗余保护）
      await ackService.markAsAcknowledged(messageId);

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
    } on SocketException catch (e) {
      LogUtil.error('UserService', '❌ Socket连接失败', e);
      throw Exception('网络连接失败，请检查服务器是否运行在 ${AppConfig.socketHost}:${AppConfig.socketPort}');
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

      // 获取 StreamClient 和 AckMessageService
      final streamClient = _ref.read(streamClientProvider);
      final ackService = _ref.read(ackMessageServiceProvider);

      // 发送登出请求到服务器
      try {
        final messageId = IdUtils.buildSnowflake() as Int64;
        final reqMsg = LogoutReqMsg.create()
          ..messageId = messageId;

        // 如果连接仍然有效，发送登出请求
        if (streamClient.status == ConnectionStatus.connected) {
          // 将消息添加到ACK服务中
          await ackService.addPendingMessage(
            messageId: messageId.toInt(),
            messageType: ByteMessageType.LoginReqMsgType.value,
            originalData: reqMsg.writeToBuffer(),
          );
          final logoutFuture = streamClient.waitForMessage<LogoutRespMsg>(
            (msg) => msg.messageId == messageId,
            timeout: Duration(seconds: 5),
          );

          streamClient.send(reqMsg);
          await logoutFuture; // 等待登出响应

          // 标记消息为已确认
          ackService.markAsAcknowledged(messageId.toInt());
        }
      } catch (e) {
        LogUtil.warning('UserService', '⚠️ 服务端登出请求失败', e);
      }

      // 获取服务
      final appConfigService = await _ref.read(appConfigServiceProvider.future);

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
