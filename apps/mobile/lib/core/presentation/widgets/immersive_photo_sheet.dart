import 'package:flutter_map/flutter_map.dart';
import 'zone_map_picker.dart';
import 'immersive_photo_sheet_geometry.dart';
import 'package:flutter/material.dart';
import 'expandable_description.dart';
import 'glass_surface.dart';
import 'stagger_reveal.dart';

class PreviewFact {
  const PreviewFact(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Full-screen photo gallery with a draggable glass details sheet.
///
/// Preserved design: "Ficha fotográfica inmersiva" (formerly
/// CasePublicationPreview). Features supply public data and real actions.
/// See docs/funcionalidades/ficha-fotografica-inmersiva.md for reuse constraints.
class ImmersivePhotoSheet extends StatefulWidget {
  const ImmersivePhotoSheet({
    required this.name,
    required this.photos,
    required this.facts,
    required this.description,
    required this.occurredAt,
    required this.privacy,
    required this.latitude,
    required this.longitude,
    this.locationLabel = 'Ubicación aproximada',
    this.eventLabel = 'Desaparición',
    this.actions,
    this.createMapTileProvider,
    super.key,
  });
  final String name, description, occurredAt, privacy;
  final double latitude, longitude;
  final String locationLabel, eventLabel;
  final List<Widget> photos;
  final List<PreviewFact> facts;
  final Widget? actions;
  final TileProvider Function()? createMapTileProvider;
  @override
  State<ImmersivePhotoSheet> createState() => _ImmersivePhotoSheetState();
}

class _ImmersivePhotoSheetState extends State<ImmersivePhotoSheet> {
  int _photo = 0;
  final _sheet = DraggableScrollableController();
  bool _expanded = false;
  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  void _toggle(double collapsed, double expanded) {
    final target = _expanded ? collapsed : expanded;
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.jumpTo(target);
    } else {
      _sheet.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final compact = height < 500 || media.textScaler.scale(16) > 22;
    final collapsed = compact ? .76 : (widget.actions == null ? .36 : .46);
    final expanded = ((height - media.padding.top - 64) / height).clamp(
      collapsed + .05,
      .94,
    );
    final nameTitle = Text(
      widget.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 48,
        height: 1.05,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        shadows: [
          Shadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xFF6E6E73),
            child: PageView(
              onPageChanged: (index) => setState(() => _photo = index),
              children: widget.photos,
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66111111),
                    Color(0x00111111),
                    Color(0xAA111111),
                  ],
                  stops: [0, .4, 1],
                ),
              ),
            ),
          ),
        ),
        if (widget.photos.length > 1)
          Positioned(
            top: media.padding.top + 72,
            left: 24,
            right: 24,
            child: Semantics(
              label: 'Foto ${_photo + 1} de ${widget.photos.length}',
              child: Row(
                children: [
                  for (var i = 0; i < widget.photos.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == _photo ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (notice) {
            final open = notice.extent > collapsed + .04;
            if (open != _expanded) setState(() => _expanded = open);
            return false;
          },
          child: DraggableScrollableSheet(
            controller: _sheet,
            initialChildSize: collapsed,
            minChildSize: collapsed,
            maxChildSize: expanded,
            snap: !media.disableAnimations,
            snapAnimationDuration: media.disableAnimations
                ? null
                : const Duration(milliseconds: 320),
            builder: (context, scrollController) => ClipRect(
              child: CustomScrollView(
                controller: scrollController,
                cacheExtent: height * 4,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    sliver: SliverToBoxAdapter(
                      child: StaggerRevealItem(
                        order: 0,
                        child: Flex(
                          direction: compact ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: compact
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            if (compact) nameTitle,
                            if (!compact) Expanded(child: nameTitle),
                            SizedBox(
                              height: compact ? 8 : 0,
                              width: compact ? 0 : 12,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB53F48),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                widget.eventLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverLayoutBuilder(
                    builder: (context, constraints) => SliverPadding(
                      padding: ImmersivePhotoSheetGeometry.cardPadding(context),
                      sliver: SliverToBoxAdapter(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                (constraints.viewportMainAxisExtent -
                                        constraints.precedingScrollExtent -
                                        ImmersivePhotoSheetGeometry.cardPadding(
                                          context,
                                        ).bottom)
                                    .clamp(0.0, double.infinity),
                          ),
                          child: StaggerRevealItem(
                            order: 1,
                            child: GlassSurface(
                              radius: ImmersivePhotoSheetGeometry.cardRadius,
                              child: ColoredBox(
                                color: const Color(0xDDF5F5F7),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: _expanded
                                          ? 'Contraer ficha'
                                          : 'Mostrar todos los datos',
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _toggle(collapsed, expanded),
                                        child: SizedBox(
                                          key: const ValueKey(
                                            'case-sheet-handle',
                                          ),
                                          height: 48,
                                          child: Center(
                                            child: Container(
                                              width: 38,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF9B9B9F),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              final single =
                                                  media.textScaler.scale(16) >
                                                  22;
                                              final width = single
                                                  ? constraints.maxWidth
                                                  : (constraints.maxWidth -
                                                            12) /
                                                        2;
                                              return Wrap(
                                                spacing: 12,
                                                runSpacing: 12,
                                                children: [
                                                  for (final fact
                                                      in widget.facts)
                                                    SizedBox(
                                                      width: width,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            fact.icon,
                                                            size: 21,
                                                            color: const Color(
                                                              0xFF111111,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              fact.label,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    height: 1.3,
                                                                    color: Color(
                                                                      0xFF111111,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          ExpandableDescription(
                                            text: widget.description,
                                          ),
                                          if (_expanded) ...[
                                            const SizedBox(height: 16),
                                            Text(
                                              widget.occurredAt,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              widget.locationLabel,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ZoneMapPicker(
                                              latitude: widget.latitude,
                                              longitude: widget.longitude,
                                              radiusMeters: 1000,
                                              onSelect: null,
                                              readOnly: true,
                                              createTileProvider:
                                                  widget.createMapTileProvider,
                                              showCenterMarker: false,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              widget.privacy,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                                color: Color(0xFF6E6E73),
                                              ),
                                            ),
                                          ],
                                          if (widget.actions != null) ...[
                                            const SizedBox(height: 20),
                                            widget.actions!,
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
