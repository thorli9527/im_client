import 'package:flutter/material.dart';

import '../../../responsive.dart';
import '../components/background.dart';
import '../components/desktop_background.dart';
import 'components/login_form.dart';
import 'components/login_screen_top_image.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Responsive(
      mobile: MobileLoginScreenWrapper(),
      desktop: DesktopLoginScreenWrapper(),
    );
  }
}

class MobileLoginScreenWrapper extends StatelessWidget {
  const MobileLoginScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: MobileLoginScreen(),
      ),
    );
  }
}

class DesktopLoginScreenWrapper extends StatelessWidget {
  const DesktopLoginScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DesktopBackground(
      child: Row(
        children: [
          Expanded(
            child: LoginScreenTopImage(),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: LoginForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
