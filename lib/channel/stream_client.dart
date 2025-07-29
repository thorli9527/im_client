// 文件路径: lib/channel/stream_client.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:riverpod/riverpod.dart'; // 添加 Riverpod 导入
import 'package:im_client/channel/stream_channel.dart';
import 'package:im_client/channel/timer/heard_heat_timer.dart';
import 'package:protobuf/protobuf.dart';
import 'package:stream_channel/stream_channel.dart';

import '../codec/message_encoder.dart';
import '../config/app_config.dart';
import '../models/generated/auth.pb.dart';
import '../models/generated/common.pbenum.dart';
import '../models/generated/status.pb.dart';
import '../utils/log_util.dart';

enum ConnectionStatus { connected, connecting, disconnected }

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

  Future<void> connect(String host, int port) async {
    if (_status != ConnectionStatus.disconnected) {
      LogUtil.warning('IMClient', '⚠️ Already connecting or connected');
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
    } catch (e) {
      LogUtil.error('IMClient', '❌ Connect failed: $e');
      _setStatus(ConnectionStatus.disconnected);
      await _channel.sink.close();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _heartbeat.stop();
    if (_status == ConnectionStatus.connected) {
      await _subscription?.cancel();
      await _channel.sink.close();
      _setStatus(ConnectionStatus.disconnected);
    }
  }

  void dispose() {
    disconnect();
    _connectionController.close();
    _messageController.close();
  }

  // 自动连接方法，在应用启动时调用
  Future<void> autoConnect() async {
    try {
      await connect(AppConfig.socketHost, AppConfig.socketPort);
      LogUtil.info('StreamClient', '✅ 自动连接成功');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ 自动连接失败', e);
      // 可以选择在此处安排重连
    }
  }

  void _onData(Uint8List data) {
    _buffer.add(data);
    final bufferData = _buffer.takeBytes();

    int offset = 0;
    while (offset + 8 <= bufferData.length) {
      try {
        final messageLength = _readUint32(bufferData, offset);
        final messageType = _readInt32(bufferData, offset + 4);
        offset += 8;

        if (offset + messageLength > bufferData.length) {
          LogUtil.warning('StreamClient', '⚠️ Incomplete data, wait for next batch');
          offset -= 8; // rollback
          break;
        }

        final payload = bufferData.sublist(offset, offset + messageLength);
        offset += messageLength;

        final type = ByteMessageType.valueOf(messageType);
        if (type == null) {
          LogUtil.warning('StreamClient', '⚠️ Unknown message type: $messageType');
          continue;
        }

        // 广播消息给等待者
        _messageController.add(MapEntry(type, payload));

        _handleIncomingMessage(type, payload);
      } catch (e, stackTrace) {
        LogUtil.error('StreamClient', '❌ Decode failed', e, stackTrace);
        _buffer.clear(); // reset buffer
        return;
      }
    }

    // 剩余未处理数据重新缓存
    if (offset < bufferData.length) {
      _buffer.add(bufferData.sublist(offset));
    }
  }

  int _readUint32(Uint8List data, int offset) {
    if (offset + 4 > data.length) throw Exception("Invalid uint32 read");
    return data.buffer.asByteData().getUint32(offset, Endian.little);
  }

  int _readInt32(Uint8List data, int offset) {
    if (offset + 4 > data.length) throw Exception("Invalid int32 read");
    return data.buffer.asByteData().getInt32(offset, Endian.little);
  }

  void _onError(Object error) {
    LogUtil.warning('IMClient', '⚠️ Socket error: $error');
    _setStatus(ConnectionStatus.disconnected);
  }

  void _onDisconnected() {
    LogUtil.info('IMClient', '🔌 Server disconnected');
    _setStatus(ConnectionStatus.disconnected);
    _heartbeat.stop(); // 停止心跳
  }

  void _setStatus(ConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _connectionController.add(newStatus);
  }

  void _handleIncomingMessage(ByteMessageType type, Uint8List payload) {
    try {
      switch (type) {
        case ByteMessageType.LoginRespMsgType:
          final msg = LoginRespMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '🔑 Auth response received, success: ${msg.success}');
          break;

        case ByteMessageType.LogoutRespMsgType:
          final msg = LogoutRespMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '🚪 Logout response received');
          break;

        case ByteMessageType.ACKMsgType:
          final msg = AckMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '✅ ACK消息收到: messageId=${msg.messageId}');
          break;

        case ByteMessageType.HeartbeatMsgType:
          LogUtil.debug('StreamClient', '💓 Heartbeat received');
          break;

        default:
          LogUtil.debug('StreamClient', '📦 Unhandled message: $type');
      }
    } catch (e, stackTrace) {
      LogUtil.error('StreamClient', '❌ Message process failed', e, stackTrace);
    }
  }

  /// 发送 protobuf 消息
  void send(GeneratedMessage message) {
    if (_status != ConnectionStatus.connected) {
      LogUtil.warning('IMClient', '🚫 无法发送消息: 未连接');
      return;
    }

    try {
      final data = message.writeToBuffer();
      final frame = encodeFramedMessage(_getMessageTypeValue(message), data);

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
      LogUtil.warning('IMClient', '🚫 无法发送消息: 未连接');
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
    // 这里需要根据具体的消息类型返回对应的整数值
    // 这只是一个示例实现，实际应该根据你的协议定义来实现
    if (message is LoginReqMsg) {
      return 2; // LoginReqMsgType
    } else if (message is LogoutReqMsg) {
      return 4; // LogoutReqMsgType
    } else if (message is HeartbeatMsg) {
      return 1; // HeartbeatMsgType
    }
    // 添加更多消息类型...

    LogUtil.warning('StreamClient', '⚠️ 未知消息类型: ${message.runtimeType}');
    return 0; // 默认值
  }

  /// 等待特定类型的消息
  Future<T> waitForMessage<T extends GeneratedMessage>(
    bool Function(T) predicate, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    final completer = Completer<T>();
    late StreamSubscription subscription;

    subscription = _messageController.stream
        .where((entry) => entry.value is T)
        .map((entry) => entry.value as T)
        .where(predicate)
        .listen((message) {
      completer.complete(message);
      subscription.cancel();
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('等待消息超时', timeout));
        subscription.cancel();
      }
    });

    return completer.future;
  }

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
