import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  Timer? _timer;

  final List<String> _images = [
    'assets/images/logo_a.jpg',
    'assets/images/logo_b.jpg',
    'assets/images/logo_c.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // 桌面平台直接跳转
    if (isDesktopPlatform()) {
      Future.delayed(Duration.zero, _navigateToNext);
      return;
    }

    // 移动平台播放图片轮播
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
        _navigateToNext();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 桌面平台不显示界面
    if (isDesktopPlatform()) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.shrink(),
      );
    }

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

    if (isMobilePlatform()) {
      Get.offAllNamed(isLoggedIn ? '/home' : '/');
    } else {
      Get.offAllNamed(isLoggedIn ? '/home' : '/login');
    }
  }

  bool isMobilePlatform() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool isDesktopPlatform() {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}
