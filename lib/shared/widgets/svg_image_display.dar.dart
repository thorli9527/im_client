import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';

class SvgImageDisplay extends StatelessWidget {
  final String assetPath;
  final String? title;
  final double? titlePadding;

  const SvgImageDisplay({
    Key? key,
    required this.assetPath,
    this.title,
    this.titlePadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: titlePadding ?? (defaultPadding * 2)),
        ],
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset(assetPath),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: titlePadding ?? (defaultPadding * 2)),
      ],
    );
  }
}
