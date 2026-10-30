import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.28),
    child: Image.asset(
      'assets/branding/app_icon.png',
      width: size,
      height: size,
      excludeFromSemantics: true,
    ),
  );
}
