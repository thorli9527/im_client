import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({Key? key}) : super(key: key);

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // 添加可拖拽区域
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              windowManager.startDragging();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        IconButton(
          onPressed: () => windowManager.minimize(),
          icon: const Icon(Icons.minimize, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => windowManager.maximize(),
          icon: const Icon(Icons.crop_square, size: 14),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => windowManager.close(),
          icon: const Icon(Icons.close, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  void onWindowResize() {
    setState(() {});
  }

  @override
  void onWindowMove() {
    setState(() {});
  }
}
