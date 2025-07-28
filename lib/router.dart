import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:im_client/views/auth/login/login_screen.dart';
import 'package:im_client/views/auth/signup/signup_screen.dart';
import 'package:im_client/views/auth/welcome/welcome_screen.dart';

// 定义路由名称常量
abstract class AppRoutes {
  static const welcome = 'welcome';
  static const login = 'login';
  static const signup = 'signup';
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: AppRoutes.welcome,
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) {
        // 可以从state.extra中获取传递的参数
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      name: AppRoutes.signup,
      builder: (BuildContext context, GoRouterState state) {
        // 可以从state.extra中获取传递的参数
        return const SignUpScreen();
      },
    ),
  ],
);
