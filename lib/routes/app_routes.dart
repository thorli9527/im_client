// lib/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:im_client/views/splash_page.dart';
import 'package:im_client/views/onboarding_page.dart';
import 'package:im_client/views/home_page.dart';
import 'package:im_client/views/login_page.dart'; // 新增导入

class AppRoutes {
  static final pages = [
    GetPage(name: '/', page: () => const SplashPage()),
    GetPage(name: '/onboarding', page: () => const OnboardingPage()),
    GetPage(name: '/login', page: () => LoginPage()), // 新增登录页路由
    GetPage(name: '/home', page: () => const HomePage()),
  ];
}
