import '../../../../core/presentation/widgets/content_refresh.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

enum PetSkeletonLayout { list, detail, editor }

class PetRefreshProgress extends StatelessWidget {
  const PetRefreshProgress({
    required this.refreshing,
    required this.child,
    super.key,
  });
  final bool refreshing;
  final Widget child;
  @override
  Widget build(BuildContext context) => ContentRefresh(
    refreshing: refreshing,
    label: 'Actualizando información de mascotas',
    child: child,
  );
}

class PetSkeleton extends StatelessWidget {
  const PetSkeleton({this.layout = PetSkeletonLayout.list, super.key});
  final PetSkeletonLayout layout;
  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: true,
    loadingLabel: 'Cargando información de mascotas',
    radius: 22,
    child: switch (layout) {
      PetSkeletonLayout.list => Column(
        children: [
          for (var i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(context),
            ),
        ],
      ),
      PetSkeletonLayout.editor => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(16) * 1.5,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: 52, child: _Shape(height: 12)),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 160, child: _Shape(height: 160, radius: 22)),
          ),
          const SizedBox(height: 20),
          const SkeletonFormFields(fieldCount: 6, multilineLast: true),
        ],
      ),
      PetSkeletonLayout.detail => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: constraints.maxWidth.clamp(112, 160).toDouble(),
                child: _Shape(
                  height: constraints.maxWidth.clamp(112, 160).toDouble(),
                  radius: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: .55,
            child: _Shape(height: 32),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 4; i++)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: .3,
                          child: _Shape(height: 12),
                        ),
                        SizedBox(height: 10),
                        FractionallySizedBox(
                          widthFactor: .65,
                          child: _Shape(height: 20),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _Shape(height: 60, radius: 24),
        ],
      ),
    },
  );
  Widget _card(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const SizedBox(width: 32, child: _Shape(height: 32, radius: 10)),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height:
                4 +
                MediaQuery.textScalerOf(context).scale(20) * 1.5 +
                MediaQuery.textScalerOf(context).scale(15) * 1.5,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: .6,
                  child: _Shape(height: 18),
                ),
                SizedBox(height: 12),
                FractionallySizedBox(
                  widthFactor: .36,
                  child: _Shape(height: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    ),
  );
}

class _Shape extends StatelessWidget {
  const _Shape({required this.height, this.radius = 6});
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
