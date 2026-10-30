import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Exact Arial brand outlines, independent of Android's fallback font.
class BrandName extends StatelessWidget {
  const BrandName({required this.textSize, super.key});

  final double textSize;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/branding/wordmark.svg',
      width: textSize * 2.86894531,
      height: textSize * 1.9,
      excludeFromSemantics: true,
      alignment: Alignment.centerLeft,
    );
  }
}
