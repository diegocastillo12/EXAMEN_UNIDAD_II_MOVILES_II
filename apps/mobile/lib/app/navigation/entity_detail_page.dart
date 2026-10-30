import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/presentation/widgets/origin_page_transition.dart';

/// Shared card-to-detail opening and return for pets and cases.
Page<void> entityDetailPage({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
  Rect? origin,
}) {
  if (origin == null) return NoTransitionPage<void>(key: key, child: child);
  final reduced = MediaQuery.disableAnimationsOf(context);
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 320),
    reverseTransitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        OriginPageTransition(
          animation: animation,
          origin: origin,
          child: child,
        ),
  );
}
