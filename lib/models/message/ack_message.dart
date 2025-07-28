import '../generated/common.pb.dart';

enum MessageStatus {
  pending,    // 等待发送
  sent,       // 已发送
  acked,      // 已确认
  failed,     // 发送失败
  timeout     // 超时
}

class MessageSendResult {
  final bool success;
  final int messageId;
  final String? error;
  final Duration? duration;

  MessageSendResult({
    required this.success,
    required this.messageId,
    this.error,
    this.duration,
  });
}

enum MessageSiteType {
  // 本地消息
  local,
  // 远程消息
  remote
}
/// 内存中的消息记录
class PendingMessage {
  // 消息ID
  final int messageId;
  // 消息类型
  final ByteMessageType messageType;
  // 消息发送
  final DateTime sendTime;
  // 消息发送方
  final MessageSiteType siteType;
  // 回调方法
  final Function(MessageSendResult)? callback;
  // 消息状态
  MessageStatus status;
  // 错误信息
  String? error;
  // 确认消息时间
  DateTime? ackTime;

  PendingMessage({
    required this.messageId,
    required this.messageType,
    required this.sendTime,
    required this.siteType,
    this.callback,
    this.status = MessageStatus.pending,
    this.error,
    this.ackTime,
  });

  /// 获取消息发送结果
  MessageSendResult get result => MessageSendResult(
    success: status == MessageStatus.acked,
    messageId: messageId,
    error: error,
    duration: ackTime?.difference(sendTime),
  );
}
