import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:im_client/channel/stream_channel.dart';
import 'package:im_client/channel/timer/heard_heat_timer.dart';
import 'package:protobuf/protobuf.dart';
import 'package:stream_channel/stream_channel.dart';

import '../codec/message_encoder.dart';
import '../models/generated/auth.pb.dart';
import '../models/generated/common.pbenum.dart';
import '../models/generated/status.pb.dart';
import '../utils/log_util.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class StreamClient {
  late StreamChannel<Uint8List> _channel;
  StreamSubscription? _subscription;
  final _connectionController = StreamController<ConnectionStatus>.broadcast();
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

      // 延时启动心跳
      Future.delayed(Duration(seconds: 10), () => _heartbeat.start(this));
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
  }

  void send(GeneratedMessage message, {Function(Object? any)? ackCallback}) {
    if (_status != ConnectionStatus.connected) {
      LogUtil.warning('IMClient', '🚫 Cannot send message: Not connected.');
      return;
    }

    ByteMessageType messageType = ByteMessageType.UNKNOWN_BYTE_MESSAGE_TYPE;
    int  messageId = 0;

    if (message is LoginReqMsg) {
      messageType = ByteMessageType.LoginReqMsgType;
      messageId = message.messageId.toInt();
    }

    final frame = encodeFramedMessage(messageType.value, message.writeToBuffer());

    try {
      _channel.sink.add(Uint8List.fromList(frame));
      LogUtil.info('StreamClient', '📤 Sent: $messageType, messageId: $messageId');
    } catch (e) {
      LogUtil.error('StreamClient', '❌ Failed to send message: $e');
      _onError(e);
    }
  }

  void _onData(Uint8List data) {
    LogUtil.debug('StreamClient', '📥 Received data: ${data.length}');
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
  }

  void _setStatus(ConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _connectionController.add(newStatus);
  }

  void _handleIncomingMessage(ByteMessageType type, Uint8List payload) {
    try {
      switch (type) {
        case ByteMessageType.LoginReqMsgType:
          final msg = LoginReqMsg.fromBuffer(payload);
          LogUtil.info('StreamClient', '🔑 Auth response received');
          break;

        default:
          LogUtil.debug('StreamClient', '📦 Unhandled message: $type');
      }
    } catch (e, stackTrace) {
      LogUtil.error('StreamClient', '❌ Message process failed', e, stackTrace);
    }
  }
}
