import 'package:flutter/material.dart';
import '../../shared/widgets/window_controls.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    this.topImage = "assets/images/main_top.png",
    this.bottomImage = "assets/images/login_bottom.png",
  }) : super(key: key);

  final String topImage, bottomImage;

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
                topImage,
                width: 120,
              ),
            ),
            // 顶部添加可拖拽区域和窗口控制按钮
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: WindowControls(),
            ),
            SafeArea(
              top: false, // 禁用默认的顶部安全区域
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
