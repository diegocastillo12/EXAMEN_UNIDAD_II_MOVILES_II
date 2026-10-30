import 'package:flutter/material.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({required this.page, super.key});
  final int page;
  static const _assets = [
    'assets/onboarding/dog_waving.png',
    'assets/onboarding/dog_with_map.png',
    'assets/onboarding/dog_and_cat.png',
  ];
  @override
  Widget build(BuildContext context) => Image.asset(
    _assets[page],
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );
}
