import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/presentation/widgets/origin_page_transition.dart';

Page<void> entityEditorPage({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
  Object? source,
}) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 320),
    reverseTransitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        OriginPageTransition(
          animation: animation,
          source: source is OriginPageSource ? source : null,
          origin: source is OriginPageSource
              ? source.bounds
              : source is Rect
              ? source
              : null,
          child: child,
        ),
    child: child,
  );
}
