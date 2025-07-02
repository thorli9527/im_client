// lib/views/splash_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_client/services/app_config_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/images/logo_a.jpg',
    'assets/images/logo_b.jpg',
    'assets/images/logo_c.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // 图片轮播：每 1 秒切换一次
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _timer.cancel(); // 取消定时器
        _navigateToNext();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToNext() async {
    final appConfig = Get.find<AppConfigService>();
    final isLoggedIn = await appConfig.isLoggedIn();

    if (isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login'); // ✅ 改为登录页
    }
  }
}
