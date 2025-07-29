// 文件路径: lib/services/message/ack_message_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:im_client/models/generated/auth.pb.dart';
import 'package:riverpod/riverpod.dart';
import 'package:isar/isar.dart';
import 'package:im_client/models/message/ack_message.dart';
import 'package:im_client/utils/log_util.dart';
import 'package:im_client/channel/stream_client.dart';
import 'package:im_client/services/database_service.dart';
import 'package:im_client/models/generated/common.pbenum.dart';
import 'package:protobuf/protobuf.dart';

class AckMessageService {
  final Ref _ref;
  final StreamController<AckMessage> _ackController = StreamController<AckMessage>.broadcast();
  final Map<int, AckMessage> _inMemoryMessages = {}; // 内存中的消息
  final Map<int, Timer> _retryTimers = {}; // 重试定时器
  bool _isOnline = true; // 网络状态
  bool _initialized = false;

  Stream<AckMessage> get ackStream => _ackController.stream;
  bool get isOnline => _isOnline;

  AckMessageService(this._ref);

  /// 初始化服务
  Future<void> init() async {
    if (_initialized) return;

    // 从数据库加载未完成的消息
    await _loadPendingMessages();

    // 监听网络状态变化
    _ref.read(streamClientProvider).connectionStream.listen((status) {
      _handleConnectionStatusChange(status);
    });

    _initialized = true;
    LogUtil.info('AckMessageService', '✅ 服务初始化完成');
  }

  /// 从数据库加载待处理消息
  Future<void> _loadPendingMessages() async {
    try {
      final dbService = await _ref.read(databaseServiceAsyncProvider.future);
      final pendingMessages = await dbService.db.ackMessages
          .filter()
          .statusEqualTo(AckStatus.sent)
          .or()
          .statusEqualTo(AckStatus.pending)
          .or()
          .statusEqualTo(AckStatus.offline)
          .findAll();

      for (final msg in pendingMessages) {
        _inMemoryMessages[msg.messageId] = msg;
        // 如果是待发送状态且网络在线，尝试发送
        if (msg.status == AckStatus.pending && _isOnline) {
          _sendMessage(msg);
        }
      }

      LogUtil.info('AckMessageService', '📥 加载 ${pendingMessages.length} 条待处理消息');
    } catch (e) {
      LogUtil.error('AckMessageService', '❌ 加载待处理消息失败', e);
    }
  }

  /// 处理连接状态变化
  void _handleConnectionStatusChange(ConnectionStatus status) {
    final wasOnline = _isOnline;
    _isOnline = status == ConnectionStatus.connected;

    if (!_isOnline) {
      LogUtil.info('AckMessageService', '🌐 网络断开');
      // 将所有待发送消息标记为离线状态
      _markPendingMessagesAsOffline();
    } else if (!wasOnline) {
      LogUtil.info('AckMessageService', '🌐 网络恢复');
      // 网络恢复后重发所有离线消息
      _resendOfflineMessages();
    }
  }

  /// 将待发送消息标记为离线状态
  void _markPendingMessagesAsOffline() {
    final pendingMessages = _inMemoryMessages.values
        .where((msg) => msg.status == AckStatus.pending)
        .toList();

    for (final msg in pendingMessages) {
      final updatedMsg = msg.copyWith(status: AckStatus.offline);
      _updateMessage(updatedMsg);
    }
  }

  /// 网络恢复后重发离线消息
  void _resendOfflineMessages() {
    final offlineMessages = _inMemoryMessages.values
        .where((msg) => msg.status == AckStatus.offline)
        .toList();

    for (final msg in offlineMessages) {
      _sendMessage(msg.copyWith(status: AckStatus.pending));
    }
  }

  /// 添加待发送消息
  Future<void> addPendingMessage({
    required int messageId,
    required int messageType, // 修改为int类型
    required Uint8List originalData,
    int maxRetries = 3,
    int retryInterval = 1000, // 修改为int类型参数
    bool persistent = true,
  }) async {
    final ackMessage = AckMessage.withType(
      messageId: messageId,
      messageType: messageType,
      originalData: originalData,
      status: _isOnline ? AckStatus.pending : AckStatus.offline,
      maxRetries: maxRetries,
      retryInterval: retryInterval, // 使用新的参数
      retryCount: 0,
    );

    _inMemoryMessages[messageId] = ackMessage;
    _ackController.add(ackMessage);

    // 持久化消息
    if (persistent) {
      await _saveMessage(ackMessage);
    }

    LogUtil.info('AckMessageService', '📤 添加待发送消息: $messageId, 类型: $messageType');

    // 如果在线，立即发送消息
    if (_isOnline) {
      _sendMessage(ackMessage);
    }
  }

  /// 发送消息
  void _sendMessage(AckMessage ackMessage) {
    if (ackMessage.status != AckStatus.pending &&
        ackMessage.status != AckStatus.offline) {
      return;
    }

    try {
      final streamClient = _ref.read(streamClientProvider);
      if (streamClient.status != ConnectionStatus.connected) {
        // 如果连接断开，标记为离线
        final updatedMsg = ackMessage.copyWith(status: AckStatus.offline);
        _updateMessage(updatedMsg);
        return;
      }

      // 更新消息状态为已发送
      final updatedMsg = ackMessage.copyWith(
        status: AckStatus.sent,
        lastSendTime: DateTime.now(),
      );

      _updateMessage(updatedMsg);

      // 发送消息
      // 注意：这里需要根据消息类型创建对应的消息对象
      _sendRawMessage(updatedMsg);

      LogUtil.info('AckMessageService', '📡 发送消息: ${updatedMsg.messageId}');

      // 设置超时检查
      _scheduleTimeoutCheck(updatedMsg);

    } catch (e) {
      LogUtil.error('AckMessageService', '❌ 发送消息失败: ${ackMessage.messageId}', e);
      _handleSendFailure(ackMessage, '发送失败: $e');
    }
  }

  /// 发送原始消息数据
  void _sendRawMessage(AckMessage ackMessage) {
    final streamClient = _ref.read(streamClientProvider);
    // 根据消息类型解析并发送
    switch (ackMessage.messageType) {
      case 2: // LoginReqMsgType
        final msg = LoginReqMsg.fromBuffer(ackMessage.originalData);
        streamClient.send(msg);
        break;
      case 4: // LogoutReqMsgType
        final msg = LogoutReqMsg.fromBuffer(ackMessage.originalData);
        streamClient.send(msg);
        break;
      default:
        LogUtil.warning('AckMessageService', '⚠️ 不支持的消息类型: ${ackMessage.messageType}');
    }
  }

  /// 安排超时检查
  void _scheduleTimeoutCheck(AckMessage ackMessage) {
    // 取消之前的定时器
    _retryTimers[ackMessage.messageId]?.cancel();

    // 设置超时定时器（默认10秒）
    final timer = Timer(Duration(seconds: 10), () {
      if (_inMemoryMessages.containsKey(ackMessage.messageId) &&
          _inMemoryMessages[ackMessage.messageId]?.status == AckStatus.sent) {
        // 消息超时
        _handleTimeout(ackMessage);
      }
    });

    _retryTimers[ackMessage.messageId] = timer;
  }

  /// 处理超时
  void _handleTimeout(AckMessage ackMessage) {
    LogUtil.warning('AckMessageService', '⏰ 消息超时: ${ackMessage.messageId}');

    if (ackMessage.canRetry()) {
      // 可以重试
      _scheduleRetry(ackMessage);
    } else {
      // 重试次数用完，标记为失败
      final updatedMsg = ackMessage.copyWith(
        status: AckStatus.timeout,
        ackTimestamp: DateTime.now(),
        errorCode: 1000,
      );

      _updateMessage(updatedMsg);
    }
  }

  /// 安排重试
  void _scheduleRetry(AckMessage ackMessage) {
    final retryDelay = ackMessage.getNextRetryDelay();
    final newRetryCount = ackMessage.retryCount + 1;

    LogUtil.info('AckMessageService', '🔄 安排重试消息: ${ackMessage.messageId}, '
        '第${newRetryCount}次重试, ${retryDelay}ms后执行');

    final timer = Timer(Duration(milliseconds: retryDelay), () {
      if (_inMemoryMessages.containsKey(ackMessage.messageId)) {
        final updatedMsg = ackMessage.copyWith(
          retryCount: newRetryCount,
          status: AckStatus.pending,
        );

        _updateMessage(updatedMsg);
        _sendMessage(updatedMsg);
      }
    });

    _retryTimers[ackMessage.messageId] = timer;
  }

  /// 处理发送失败
  void _handleSendFailure(AckMessage ackMessage, String error) {
    if (ackMessage.canRetry()) {
      // 可以重试
      _scheduleRetry(ackMessage);
    } else {
      // 重试次数用完，标记为失败
      final updatedMsg = ackMessage.copyWith(
        status: AckStatus.failed,
        ackTimestamp: DateTime.now(),
        errorCode: 1000,
      );

      _updateMessage(updatedMsg);
    }
  }

  /// 标记消息为已确认
  Future<void> markAsAcknowledged(int messageId) async {
    final ackMessage = _inMemoryMessages[messageId];
    if (ackMessage != null) {
      // 取消重试定时器
      _retryTimers[messageId]?.cancel();
      _retryTimers.remove(messageId);

      final updatedMsg = ackMessage.copyWith(
        status: AckStatus.acknowledged,
        ackTimestamp: DateTime.now(),
      );

      _updateMessage(updatedMsg);
      LogUtil.info('AckMessageService', '✅ 消息已确认: $messageId');
    } else {
      LogUtil.warning('AckMessageService', '⚠️ 尝试确认不存在的消息: $messageId');
    }
  }

  /// 标记消息为失败
  Future<void> markAsFailed(int messageId, [int? errorCode]) async {
    final ackMessage = _inMemoryMessages[messageId];
    if (ackMessage != null) {
      // 取消重试定时器
      _retryTimers[messageId]?.cancel();
      _retryTimers.remove(messageId);

      final updatedMsg = ackMessage.copyWith(
        status: AckStatus.failed,
        ackTimestamp: DateTime.now(),
        errorCode: errorCode,
      );

      _updateMessage(updatedMsg);
      LogUtil.info('AckMessageService', '❌ 消息失败: $messageId, 错误: $errorCode');
    }
  }

  /// 更新消息状态
  void _updateMessage(AckMessage ackMessage) {
    _inMemoryMessages[ackMessage.messageId] = ackMessage;
    _ackController.add(ackMessage);

    // 持久化更新
    _saveMessage(ackMessage);
  }

  /// 保存消息到数据库
  Future<void> _saveMessage(AckMessage ackMessage) async {
    try {
      final dbService = await _ref.read(databaseServiceAsyncProvider.future);
      await dbService.db.writeTxn(() => dbService.db.ackMessages.put(ackMessage));
    } catch (e) {
      LogUtil.error('AckMessageService', '❌ 保存消息到数据库失败: ${ackMessage.messageId}', e);
    }
  }

  /// 获取消息状态
  AckMessage? getMessageStatus(int messageId) {
    return _inMemoryMessages[messageId];
  }

  /// 检查消息是否已确认
  bool isAcknowledged(int messageId) {
    final message = _inMemoryMessages[messageId];
    return message?.status == AckStatus.acknowledged;
  }

  void dispose() {
    // 清理定时器
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();

    // 关闭流控制器
    _ackController.close();
  }
}

// Riverpod provider
final ackMessageServiceProvider = Provider<AckMessageService>((ref) {
  final service = AckMessageService(ref);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
