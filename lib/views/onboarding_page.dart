// lib/views/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("欢迎")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("这是引导页"),
            ElevatedButton(
              onPressed: () => Get.toNamed('/login'), // 修改为跳转登录页
              child: const Text("去登录"),
            ),
          ],
        ),
      ),
    );
  }
}
