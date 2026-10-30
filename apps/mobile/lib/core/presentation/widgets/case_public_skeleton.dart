import 'package:flutter/material.dart';
import 'immersive_photo_sheet_geometry.dart';
import 'loading_shimmer.dart';
import 'zone_map_picker.dart';
import 'glass_surface.dart';

/// Geometry of a public case, without fictional metadata, photos or map tiles.
class CasePublicSkeleton extends StatelessWidget {
  const CasePublicSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context);
    return LoadingShimmer(
      isLoading: true,
      isAction: false,
      radius: 0,
      loadingLabel: 'Consultando ficha del caso',
      child: ExcludeSemantics(
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFF5F5F7))),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: ImmersivePhotoSheetGeometry.photoSpace(context),
                  ),
                  Padding(
                    padding: ImmersivePhotoSheetGeometry.titlePadding,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: .6,
                        child: _Shape(
                          height: scale.scale(48) * 1.05,
                          radius: 12,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: ImmersivePhotoSheetGeometry.cardPadding(context),
                    child: GlassSurface(
                      radius: ImmersivePhotoSheetGeometry.cardRadius,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Shape(height: scale.scale(15) * 1.3),
                            const SizedBox(height: 16),
                            _Shape(height: scale.scale(16) * 1.5),
                            const SizedBox(height: 8),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: .75,
                              child: _Shape(height: scale.scale(16) * 1.5),
                            ),
                            const SizedBox(height: 16),
                            _Shape(height: scale.scale(20) * 1.3),
                            const SizedBox(height: 20),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: .65,
                              child: _Shape(height: scale.scale(20) * 1.3),
                            ),
                            const SizedBox(height: 12),
                            const _Shape(
                              key: ValueKey('case-skeleton-map'),
                              height: ZoneMapPicker.viewportHeight,
                              radius: 22,
                            ),
                            const SizedBox(height: 8),
                            _Shape(height: scale.scale(13) * 1.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shape extends StatelessWidget {
  const _Shape({required this.height, this.radius = 8, super.key});
  final double height, radius;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
