import '../../theme/app_typography.dart';
import 'scroll_safe_area.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'brand_wordmark.dart';
import 'glass_navigation_button.dart';
import 'stagger_reveal.dart';

/// Shared header geometry: changing form height must not move the brand/title.
class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    required this.title,
    required this.child,
    this.onClose,
    this.showClose = false,
    this.reveal = false,
    this.revealBrand = true,
    this.revealClose = true,
    this.contentBuilder,
    super.key,
  });

  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final bool showClose;
  final bool reveal;
  final bool revealBrand;
  final bool revealClose;
  final Widget Function(Widget)? contentBuilder;

  Widget _item(int order, Widget child, {bool enabled = true}) =>
      reveal && enabled ? StaggerRevealItem(order: order, child: child) : child;
  Widget _content(Widget content) => contentBuilder?.call(content) ?? content;

  @override
  Widget build(BuildContext context) => ScrollSafeArea(
    top: true,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  // Retain the login's normal-scale anchor, independent of form.
                  padding: EdgeInsets.fromLTRB(
                    24,
                    math.max(
                      28,
                      (constraints.maxHeight -
                              MediaQuery.paddingOf(context).bottom -
                              660) /
                          2,
                    ),
                    24,
                    ScrollSafeArea.bottomPadding(context, 28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _item(
                        1,
                        const Align(
                          key: ValueKey('auth-brand'),
                          alignment: Alignment.centerLeft,
                          child: BrandWordmark(iconSize: 80, textSize: 32),
                        ),
                        enabled: revealBrand,
                      ),
                      const SizedBox(height: 14),
                      _content(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (title != null) ...[
                              _item(
                                2,
                                Text(
                                  title!,
                                  key: const ValueKey('auth-title'),
                                  textAlign: TextAlign.left,
                                  style: AppTypography.primaryTitle,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showClose)
                Positioned(
                  top: 0,
                  left: 16,
                  child: _item(
                    0,
                    GlassNavigationButton(
                      onPressed: onClose,
                      tooltip: 'Cerrar registro',
                      icon: Icons.close_rounded,
                    ),
                    enabled: revealClose,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
