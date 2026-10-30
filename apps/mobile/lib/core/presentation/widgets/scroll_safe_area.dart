import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps the scroll viewport behind the gesture area. Reserve the bottom inset
/// in scroll content and floating actions instead of clipping the viewport.
class ScrollSafeArea extends StatelessWidget {
  const ScrollSafeArea({
    required this.child,
    this.top = false,
    this.lightNavigationIcons = false,
    super.key,
  });
  final Widget child;
  final bool top, lightNavigationIcons;

  static double bottomPadding(BuildContext context, double spacing) =>
      spacing + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: lightNavigationIcons
          ? Brightness.light
          : Brightness.dark,
    ),
    child: SafeArea(top: top, bottom: false, child: child),
  );
}
