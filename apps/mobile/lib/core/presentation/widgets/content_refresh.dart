import 'package:flutter/material.dart';
import 'loading_shimmer.dart';

/// Retains layout and data while explicitly refreshing the same identity.
class ContentRefresh extends StatelessWidget {
  const ContentRefresh({
    required this.refreshing,
    required this.child,
    required this.label,
    super.key,
  });
  final bool refreshing;
  final Widget child;
  final String label;
  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: refreshing,
    isAction: false,
    loadingLabel: label,
    radius: 22,
    child: child,
  );
}
