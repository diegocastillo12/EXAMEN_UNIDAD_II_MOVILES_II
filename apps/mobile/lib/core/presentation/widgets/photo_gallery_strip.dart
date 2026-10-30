import 'package:flutter/material.dart';

/// Shared horizontal gallery geometry for pet details, editors and reports.
class PhotoGalleryStrip extends StatelessWidget {
  const PhotoGalleryStrip({required this.children, super.key});
  final List<Widget> children;
  static double detailTileSize(double availableWidth) =>
      availableWidth.clamp(112, 160).toDouble();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: children),
  );
}

class PhotoGalleryTile extends StatelessWidget {
  const PhotoGalleryTile({
    required this.id,
    required this.child,
    required this.size,
    this.remove,
    this.pending = false,
    this.invalid = false,
    this.primary = false,
    this.selectPrimary,
    this.selected,
    this.onSelectionChanged,
    this.selectionLabel = '',
    super.key,
  });
  final String id, selectionLabel;
  final Widget child;
  final double size;
  final VoidCallback? remove, selectPrimary;
  final bool pending, invalid, primary;
  final bool? selected;
  final ValueChanged<bool?>? onSelectionChanged;
  @override
  Widget build(BuildContext context) => Padding(
    key: ValueKey(id),
    padding: const EdgeInsets.only(right: 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: const Color(0xFFF5F5F7), child: child),
            if (pending)
              const Align(
                alignment: Alignment.bottomCenter,
                child: ColoredBox(
                  color: Color(0xD924282A),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Pendiente',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ),
            if (invalid)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFB53F48),
                      width: 3.5,
                    ),
                  ),
                ),
              ),
            if (remove != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'Quitar foto',
                  onPressed: remove,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xD924282A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            if (selected != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ColoredBox(
                  color: const Color(0xD9111111),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      label:
                          'Incluir ${selectionLabel.toLowerCase()} en la publicación',
                      child: Checkbox(
                        key: ValueKey('photo_selection_$id'),
                        value: selected,
                        onChanged: onSelectionChanged,
                        activeColor: Colors.white,
                        checkColor: const Color(0xFF111111),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            if (selectPrimary != null || primary)
              Positioned(
                bottom: 0,
                left: 0,
                child: Semantics(
                  selected: primary,
                  label: primary ? 'Foto principal' : 'Elegir foto principal',
                  child: IconButton(
                    tooltip: primary
                        ? 'Foto principal'
                        : 'Elegir foto principal',
                    onPressed: selectPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xD9111111),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: Icon(
                      primary ? Icons.star_rounded : Icons.star_outline_rounded,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
