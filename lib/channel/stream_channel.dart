import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:stream_channel/stream_channel.dart';

/// 创建一个 StreamChannel 封装的 TCP Socket
/// 支持双向异步通信
Future<StreamChannel<Uint8List>> createSocketChannel(String host, int port,
    {Duration timeout = const Duration(seconds: 5)}) async {
  late Socket socket;

  try {
    socket = await Socket.connect(host, port).timeout(timeout);
    socket.setOption(SocketOption.tcpNoDelay, true);
  } catch (e) {
    throw SocketException('🚫 无法连接 $host:$port - $e');
  }

  // 输入流（来自服务器）
  final input = socket.map((event) => Uint8List.fromList(event));

  // 输出流控制器
  final controller = StreamController<Uint8List>();

  // 输出监听 => 写入 socket
  final outputSub = controller.stream.listen(
    socket.add,
    onError: (e) {
      print('⚠️ Send error: $e');
      socket.destroy();
    },
    onDone: () => socket.destroy(),
    cancelOnError: true,
  );

  // socket 关闭时清理资源
  socket.done.then((_) async {
    await outputSub.cancel();
    await controller.close();
    print('🔌 Socket closed');
  });

  return StreamChannel<Uint8List>(input, controller.sink);
}
