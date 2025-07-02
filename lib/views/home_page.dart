// lib/views/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("主页")),
      body: const Center(child: Text("欢迎登录！")),
    );
  }
}
