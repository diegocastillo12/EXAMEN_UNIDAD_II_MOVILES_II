import '../../../../core/theme/app_typography.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal_text.dart';

import 'onboarding_illustration.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.page,
    required this.isActive,
    required this.title,
    required this.description,
    super.key,
  });

  final int page;
  final bool isActive;
  final String title;
  final String description;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StaggerReveal(
      play: widget.isActive,
      count:
          widget.title.split('\n').length +
          widget.description.split('\n').length,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: math.min(
                    constraints.maxWidth - 24,
                    (constraints.maxHeight * .68)
                        .clamp(180.0, 460.0)
                        .toDouble(),
                  ),
                  width: double.infinity,
                  child: OnboardingIllustration(page: widget.page),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: StaggerRevealText(
                    text: widget.title,
                    startOrder: 0,
                    style: AppTypography.primaryTitle,
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: StaggerRevealText(
                    text: widget.description,
                    startOrder: widget.title.split('\n').length,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.3,
                      color: Color(0xFF646772),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
