import 'package:flutter/material.dart';
import 'case_public_cards.dart';
import 'loading_shimmer.dart';

/// Matches the public cards without requesting photos, metadata or map tiles.
class CasePublicCardsSkeleton extends StatelessWidget {
  const CasePublicCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: true,
    isAction: false,
    radius: 28,
    loadingLabel: 'Consultando ficha del caso',
    child: ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AspectRatio(aspectRatio: 1.35, child: _Shape()),
          const SizedBox(height: 12),
          const _Shape(height: 68),
          const SizedBox(height: 12),
          const CasePublicGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Shape(height: 50),
                SizedBox(height: 16),
                _Shape(height: 50),
                SizedBox(height: 16),
                _Shape(height: 45),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const CasePublicGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Shape(height: 24),
                SizedBox(height: 12),
                _Shape(key: ValueKey('case-skeleton-map'), height: 180),
                SizedBox(height: 12),
                _Shape(height: 32),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Shape extends StatelessWidget {
  const _Shape({this.height, super.key});
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFDCE1E7),
      borderRadius: BorderRadius.circular(24),
    ),
  );
}
