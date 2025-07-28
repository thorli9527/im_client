import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/constants.dart';
import '../../../../shared/widgets/svg_image_display.dar.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgImageDisplay(
      assetPath: "assets/icons/login.svg",
      title: "LOGIN",
      titlePadding: defaultPadding * 2,
    );
  }
}
