import 'package:flutter/material.dart';
import '../../responsive.dart';
import '../components/background.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';
import '../../shared/widgets/window_controls.dart'; // 添加导入

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackgroundWithControls(); // 使用带控制按钮的背景
  }
}

class BackgroundWithControls extends StatelessWidget {
  const BackgroundWithControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/main_top.png",
                width: 120,
              ),
            ),
            // 添加窗口控制按钮到右上角
            const Positioned(
              top: 10,
              right: 10,
              child: WindowControls(),
            ),
            const SingleChildScrollView(
              child: SafeArea(
                child: Responsive(
                  desktop: DesktopWelcomeScreen(),
                  mobile: MobileWelcomeScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 新增桌面端布局组件
class DesktopWelcomeScreen extends StatelessWidget {
  const DesktopWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 450,
        child: LoginAndSignupBtn(),
      ),
    );
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
