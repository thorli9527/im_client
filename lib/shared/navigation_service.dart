import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static void navigateToLogin(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/login');
    } else {
      context.push('/login');
    }
  }

  static void navigateToSignUp(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/signup');
    } else {
      context.push('/signup');
    }
  }

  static void navigateToWelcome(BuildContext context, {bool replace = false}) {
    if (replace) {
      context.go('/');
    } else {
      context.push('/');
    }
  }
}
