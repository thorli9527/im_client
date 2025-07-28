import 'dart:async';

import '../../models/message/ack_message.dart';

class AckMessageService {
  // 单例（可选）
  static final AckMessageService _instance = AckMessageService._internal();

  factory AckMessageService() => _instance;

  AckMessageService._internal();

  final Map<int, PendingMessage> _pending = {};

  /// 消息最大等待时间（可配置）
  Duration timeout = const Duration(seconds: 15);

  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkTimeouts(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 添加新消息
  void addMessage(PendingMessage msg) {
    _pending[msg.messageId] = msg;
  }

  /// 标记消息已发送（可选）
  void markSent(int messageId) {
    final msg = _pending[messageId];
    if (msg != null && msg.status == MessageStatus.pending) {
      msg.status = MessageStatus.sent;
    }
  }

  /// 收到 ack 确认
  void markAcked(int messageId) {
    final msg = _pending.remove(messageId);
    if (msg != null) {
      msg.status = MessageStatus.acked;
      msg.ackTime = DateTime.now();
      msg.callback?.call(msg.result);
    }
  }

  /// 标记失败
  void markFailed(int messageId, {String? error}) {
    final msg = _pending.remove(messageId);
    if (msg != null) {
      msg.status = MessageStatus.failed;
      msg.error = error;
      msg.callback?.call(msg.result);
    }
  }

  /// 内部定时器：超时检测
  void _checkTimeouts() {
    final now = DateTime.now();
    final expiredIds = <int>[];

    _pending.forEach((id, msg) {
      if (now.difference(msg.sendTime) > timeout) {
        expiredIds.add(id);
      }
    });

    for (final id in expiredIds) {
      final msg = _pending.remove(id);
      if (msg != null) {
        msg.status = MessageStatus.timeout;
        msg.error = "消息发送超时";
        msg.callback?.call(msg.result);
      }
    }
  }

  /// 是否存在指定消息
  bool contains(int messageId) => _pending.containsKey(messageId);

  /// 当前等待确认的消息数量
  int get pendingCount => _pending.length;
}
