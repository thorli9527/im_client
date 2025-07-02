// lib/main.dart
import 'package:flutter/material.dart';
import 'package:im_client/core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IMClientApp.run(); // ✅ 等待异步初始化
}
