import 'package:flutter/material.dart';
import 'case_photo.dart';
import 'entity_card_surface.dart';
import '../../domain/entities/public_case_card.dart';

/// Natural card heights preserve full text when accessibility scaling increases.
class PublicCaseGrid extends StatelessWidget {
  const PublicCaseGrid({required this.items, required this.onOpen, super.key})
    : loading = false;
  const PublicCaseGrid.skeleton({super.key})
    : items = const [],
      onOpen = null,
      loading = true;
  final List<PublicCaseCard> items;
  final bool loading;
  final void Function(PublicCaseCard, BuildContext)? onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth >= 280 &&
              MediaQuery.textScalerOf(context).scale(16) <= 21
          ? 2
          : 1;
      final grid = Column(
        children: [
          for (
            var start = 0;
            start < (loading ? 4 : items.length);
            start += columns
          )
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0; column < columns; column++) ...[
                      if (column > 0) const SizedBox(width: 14),
                      Expanded(
                        child: loading
                            ? const _CardSkeleton()
                            : start + column >= items.length
                            ? const SizedBox.shrink()
                            : _CaseCard(
                                item: items[start + column],
                                onOpen: onOpen,
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
      return grid;
    },
  );
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: EntityCardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ColoredBox(color: Color(0xFFE5E5EA)),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: .75,
                  child: SizedBox(
                    height: 20,
                    child: ColoredBox(color: Color(0xFFE5E5EA)),
                  ),
                ),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: .9,
                  child: SizedBox(
                    height: 14,
                    child: ColoredBox(color: Color(0xFFE5E5EA)),
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

class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.item, required this.onOpen});
  final PublicCaseCard item;
  final void Function(PublicCaseCard, BuildContext)? onOpen;

  @override
  Widget build(BuildContext context) {
    final title = item.name.isEmpty ? 'Sin nombre' : item.name;
    final status = item.status == PublicCaseStatus.active
        ? 'Abierto'
        : 'Resuelto';
    return Builder(
      builder: (source) => EntityCardSurface(
        onTap: onOpen == null ? null : () => onOpen!(item, source),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.coverUri == null
                      ? const ColoredBox(
                          color: Color(0xFFE5E5EA),
                          child: Center(
                            child: Icon(
                              Icons.pets_outlined,
                              size: 40,
                              color: Color(0xFF6E6E73),
                            ),
                          ),
                        )
                      : CasePhotoView.network(
                          item.coverUri!,
                          semanticLabel: 'Foto de $title',
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 6,
                      children: [_CaseBadge(label: status)],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  if (item.distanceMeters != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.distanceMeters! < 1000
                          ? 'A menos de 1 km'
                          : 'A ${(item.distanceMeters! / 1000).round()} km',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Color(0xFF6E6E73),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseBadge extends StatelessWidget {
  const _CaseBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xF5FFFFFF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111111),
        ),
      ),
    ),
  );
}
