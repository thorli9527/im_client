// 文件路径: lib/channel/stream_client.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:protobuf/protobuf.dart';

import 'stream_channel.dart';
import 'timer/heard_heat_timer.dart';
import '../codec/message_encoder.dart';
import '../config/app_config.dart';
import '../models/generated/auth.pb.dart';
import '../models/generated/common.pbenum.dart';
import '../models/generated/status.pb.dart';
import '../utils/log_util.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected
}

class StreamClient {
  late StreamChannel<Uint8List> _channel;
  StreamSubscription? _subscription;
  final _connectionController = StreamController<ConnectionStatus>.broadcast();
  final _messageController = StreamController<MapEntry<ByteMessageType, Uint8List>>.broadcast();
  final _heartbeat = HeartbeatTimer();
  final _buffer = BytesBuilder(copy: false);
  ConnectionStatus _status = ConnectionStatus.disconnected;

  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  ConnectionStatus get status => _status;

  /// 建立 WebSocket 连接
  Future<void> connect(String host, int port) async {
    if (_status != ConnectionStatus.disconnected) {
      LogUtil.warning('StreamClient', '⚠️ 连接已在进行中或已建立');
      return;
    }

    _setStatus(ConnectionStatus.connecting);
    try {
      _channel = await createSocketChannel(host, port);
      _subscription = _channel.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: true,
      );
      _setStatus(ConnectionStatus.connected);

      // 启动心跳，每60秒一次
      _heartbeat.start(this, interval: Duration(seconds: 60));
      LogUtil.info('StreamClient', '✅ 连接已建立 $host:$port');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ 连接失败: $e');
      _setStatus(ConnectionStatus.disconnected);
      await _channel.sink.close();
      rethrow;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _heartbeat.stop();
    if (_status == ConnectionStatus.connected) {
      await _subscription?.cancel();
      await _channel.sink.close();
      _setStatus(ConnectionStatus.disconnected);
      LogUtil.info('StreamClient', '🔌 连接已断开');
    }
  }

  /// 关闭所有资源
  void dispose() {
    disconnect();
    _connectionController.close();
    _messageController.close();
    LogUtil.info('StreamClient', '🧹 资源已释放');
  }

  /// 自动连接方法，在应用启动时调用
  Future<void> autoConnect() async {
    try {
      await connect(AppConfig.socketHost, AppConfig.socketPort);
      LogUtil.info('StreamClient', '✅ 自动连接成功');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ 自动连接失败', e);
    }
  }

  /// 处理接收到的数据
  void _onData(Uint8List data) {
    LogUtil.debug('StreamClient', '📥 收到数据: ${data.length} 字节');
    _buffer.add(data);
    final bufferData = _buffer.takeBytes();

    int offset = 0;
    while (offset + 5 <= bufferData.length) {
      try {
        // 读取消息长度(4字节大端)
        final messageLength = bufferData.buffer.asByteData().getUint32(offset, Endian.big);
        offset += 4;

        // 检查是否有足够的数据
        if (offset + messageLength > bufferData.length) {
          LogUtil.warning('StreamClient', '⚠️ 数据不完整，等待下一批数据');
          offset -= 4;
          break;
        }

        // 检查消息长度是否有效
        if (messageLength < 1) {
          LogUtil.warning('StreamClient', '⚠️ 无效的消息长度: $messageLength');
          offset += messageLength;
          continue;
        }

        // 提取消息类型(第一个字节)
        final messageTypeByte = bufferData[offset];
        final type = ByteMessageType.valueOf(messageTypeByte);

        if (type == null) {
          LogUtil.warning('StreamClient', '⚠️ 未知消息类型: $messageTypeByte');
          offset += messageLength;
          continue;
        }

        // 提取protobuf数据(去掉类型字节)
        final payloadLength = messageLength - 1;
        if (payloadLength < 0) {
          LogUtil.warning('StreamClient', '⚠️ 无效的负载长度: $payloadLength');
          offset += messageLength;
          continue;
        }

        final payload = bufferData.sublist(offset + 1, offset + 1 + payloadLength);
        offset += messageLength;

        // 广播消息给等待者
        _messageController.add(MapEntry(type, payload));

        // 处理内部消息
        _handleIncomingMessage(type, payload);
      } catch (e, stackTrace) {
        LogUtil.error('StreamClient', '❌ 解码失败', e, stackTrace);
        _buffer.clear();
        return;
      }
    }

    // 剩余未处理数据重新缓存
    if (offset < bufferData.length) {
      _buffer.add(bufferData.sublist(offset));
    }
  }

  /// 处理Socket错误
  void _onError(Object error) {
    LogUtil.warning('StreamClient', '⚠️ Socket错误: $error');
    _setStatus(ConnectionStatus.disconnected);
  }

  /// 处理连接断开
  void _onDisconnected() {
    LogUtil.info('StreamClient', '🔌 服务器断开连接');
    _setStatus(ConnectionStatus.disconnected);
    _heartbeat.stop();
  }

  /// 更新连接状态
  void _setStatus(ConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _connectionController.add(newStatus);
  }

  /// 处理传入的消息
  void _handleIncomingMessage(ByteMessageType type, Uint8List payload) {
    try {
      switch (type) {
        case ByteMessageType.LoginRespMsgType:
          final msg = LoginRespMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '🔑 认证响应收到, 成功: ${msg.success}');
          break;

        case ByteMessageType.LogoutRespMsgType:
          final msg = LogoutRespMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '🚪 登出响应收到');
          break;

        case ByteMessageType.ACKMsgType:
          final msg = AckMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '✅ ACK消息收到: messageId=${msg.messageId}');
          break;

        case ByteMessageType.HeartbeatMsgType:
          LogUtil.debug('StreamClient', '💓 心跳包收到');
          break;

        default:
          LogUtil.debug('StreamClient', '📦 未处理消息: $type');
      }
    } catch (e, stackTrace) {
      LogUtil.error('StreamClient', '❌ 消息处理失败', e, stackTrace);
    }
  }

  /// 发送 protobuf 消息
  void send(GeneratedMessage message) {
    if (_status != ConnectionStatus.connected) {
      LogUtil.warning('StreamClient', '🚫 无法发送消息: 未连接');
      return;
    }

    try {
      final data = message.writeToBuffer();
      final messageType = _getMessageTypeValue(message);
      final frame = encodeFramedMessage(messageType, data);

      _channel.sink.add(Uint8List.fromList(frame));
      LogUtil.info('StreamClient', '📤 发送消息: ${message.runtimeType}');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ 发送消息失败: $e');
      _onError(e);
    }
  }

  /// 发送原始数据
  void sendRaw(int messageType, Uint8List data, int messageId) {
    if (_status != ConnectionStatus.connected) {
      LogUtil.warning('StreamClient', '🚫 无法发送消息: 未连接');
      return;
    }

    try {
      final frame = encodeFramedMessage(messageType, data);
      _channel.sink.add(Uint8List.fromList(frame));
      LogUtil.info('StreamClient', '📤 发送原始数据: messageType=$messageType, messageId=$messageId');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ 发送原始数据失败: $e');
      _onError(e);
    }
  }

  /// 根据消息类型获取对应的整数值
  int _getMessageTypeValue(GeneratedMessage message) {
    if (message is LoginReqMsg) {
      return ByteMessageType.LoginReqMsgType.value;
    } else if (message is LogoutReqMsg) {
      return ByteMessageType.LogoutReqMsgType.value;
    } else if (message is HeartbeatMsg) {
      return ByteMessageType.HeartbeatMsgType.value;
    }

    LogUtil.warning('StreamClient', '⚠️ 未知消息类型: ${message.runtimeType}');
    return ByteMessageType.UNKNOWN_BYTE_MESSAGE_TYPE.value;
  }

  /// 等待特定类型的消息
  Future<T> waitForMessage<T extends GeneratedMessage>(
    bool Function(T) predicate, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    final completer = Completer<T>();
    late StreamSubscription subscription;

    subscription = _messageController.stream
        .where((entry) => _isMessageType<T>(entry.key))
        .map((entry) => _parseMessage<T>(entry.value))
        .where((msg) => predicate(msg))
        .listen((message) {
      completer.complete(message);
      subscription.cancel();
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
        subscription.cancel();
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('等待消息超时', timeout));
        subscription.cancel();
      }
    });

    return completer.future;
  }

  /// 根据消息类型判断是否为目标类型
  bool _isMessageType<T extends GeneratedMessage>(ByteMessageType type) {
    if (T == LoginRespMsg) {
      return type == ByteMessageType.LoginRespMsgType;
    } else if (T == LogoutRespMsg) {
      return type == ByteMessageType.LogoutRespMsgType;
    }
    return false;
  }

  /// 解析消息
  T _parseMessage<T extends GeneratedMessage>(Uint8List data) {
    if (T == LoginRespMsg) {
      return LoginRespMsg.fromBuffer(data) as T;
    } else if (T == LogoutRespMsg) {
      return LogoutRespMsg.fromBuffer(data) as T;
    }
    throw Exception('不支持的消息类型');
  }

  /// 关闭连接
  Future<void> closeConnection() async {
    await disconnect();
  }
}

// Riverpod Provider
final streamClientProvider = Provider<StreamClient>((ref) {
  return StreamClient();
});

// 自动连接的Provider
final autoConnectProvider = FutureProvider<void>((ref) async {
  final streamClient = ref.read(streamClientProvider);
  await streamClient.autoConnect();
  return;
});
