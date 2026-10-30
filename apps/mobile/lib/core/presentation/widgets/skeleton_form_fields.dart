import 'package:flutter/material.dart';

/// Placeholder geometry only; the caller supplies real loading state and shimmer.
class SkeletonFormFields extends StatelessWidget {
  const SkeletonFormFields({
    required this.fieldCount,
    this.multilineLast = false,
    super.key,
  }) : assert(fieldCount > 0);
  final int fieldCount;
  final bool multilineLast;
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < fieldCount; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _FormShape(
              height:
                  32 +
                  scale.scale(13) * 1.3 +
                  4 +
                  scale.scale(16) *
                      27 /
                      16 *
                      (multilineLast && i == fieldCount - 1 ? 2 : 1),
              radius: 22,
            ),
          ),
        _FormShape(height: 36 + scale.scale(18) * 1.5, radius: 24),
      ],
    );
  }
}

class _FormShape extends StatelessWidget {
  const _FormShape({required this.height, required this.radius});
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E5EA),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
