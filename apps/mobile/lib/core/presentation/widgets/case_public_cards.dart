import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'expandable_description.dart';
import 'glass_surface.dart';
import 'stagger_reveal.dart';
import 'zone_map_picker.dart';

class CasePublicFact {
  const CasePublicFact(this.label, this.value);
  final String label, value;
}

/// Public projection only: features supply metadata and authorized real actions.
/// The previous full-screen design remains in ImmersivePhotoSheet.
class CasePublicCards extends StatelessWidget {
  const CasePublicCards({
    required this.name,
    required this.eventLabel,
    required this.photos,
    required this.facts,
    required this.description,
    required this.occurredAt,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.privacy,
    this.actions,
    this.contact,
    this.createMapTileProvider,
    this.offline = false,
    super.key,
  });

  final String name,
      eventLabel,
      description,
      occurredAt,
      locationLabel,
      privacy;
  final List<Widget> photos;
  final List<CasePublicFact> facts;
  final double latitude, longitude;
  final Widget? actions;
  final Widget? contact;
  final bool offline;
  final TileProvider Function()? createMapTileProvider;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: _CasePhotoCard(
          name: name,
          eventLabel: eventLabel,
          photos: photos,
        ),
      ),
      const SizedBox(height: 12),
      if (contact != null)
        StaggerRevealItem(order: 1, preserveBackdrop: true, child: contact!),
      StaggerRevealItem(
        order: 2,
        preserveBackdrop: true,
        child: CasePublicGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final single =
                      MediaQuery.textScalerOf(context).scale(16) > 22;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final fact in facts)
                        SizedBox(
                          width: single
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 16) / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fact.label, style: _labelStyle),
                              const SizedBox(height: 3),
                              Text(fact.value, style: _valueStyle),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (description.trim().isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0x1F454746)),
                ),
                const Text('Rasgos', style: _labelStyle),
                const SizedBox(height: 4),
                ExpandableDescription(text: description),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      StaggerRevealItem(
        order: 3,
        preserveBackdrop: true,
        child: CasePublicGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(locationLabel, style: _valueStyle),
              const SizedBox(height: 6),
              Text(occurredAt, style: _labelStyle),
              const SizedBox(height: 12),
              if (offline)
                Text(
                  'Ubicación pública aproximada: ${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}. Mapa disponible al conectar.',
                )
              else
                ZoneMapPicker(
                  latitude: latitude,
                  longitude: longitude,
                  radiusMeters: 1000,
                  onSelect: null,
                  readOnly: true,
                  compactAttribution: true,
                  fitRadius: true,
                  showRadius: false,
                  showCenterMarker: false,
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 72,
                      height: 72,
                      child: Semantics(
                        label: 'Ubicación pública aproximada',
                        child: Container(
                          padding: const EdgeInsets.all(23),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x30459FF6),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2887EF),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  height: 180,
                  borderRadius: 22,
                  createTileProvider: createMapTileProvider,
                ),
              const SizedBox(height: 10),
              Text(privacy, style: _labelStyle.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
      if (actions != null) ...[
        const SizedBox(height: 16),
        StaggerRevealItem(order: 4, child: actions!),
      ],
    ],
  );
}

const _labelStyle = TextStyle(
  fontSize: 14,
  height: 1.4,
  color: Color(0xFF626975),
);
const _valueStyle = TextStyle(
  fontSize: 17,
  height: 1.3,
  fontWeight: FontWeight.w600,
  color: Color(0xFF111111),
);

/// Silver pearl tint over the existing shared blur and polished glass rim.
class CasePublicGlassCard extends StatelessWidget {
  const CasePublicGlassCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 28,
    finish: GlassSurfaceFinish.frosted,
    backdropBlendMode: BlendMode.src,
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
}

class _CasePhotoCard extends StatefulWidget {
  const _CasePhotoCard({
    required this.name,
    required this.eventLabel,
    required this.photos,
  });
  final String name, eventLabel;
  final List<Widget> photos;

  @override
  State<_CasePhotoCard> createState() => _CasePhotoCardState();
}

class _CasePhotoCardState extends State<_CasePhotoCard> {
  int _photo = 0;

  @override
  void didUpdateWidget(_CasePhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name ||
        oldWidget.photos.length != widget.photos.length) {
      _photo = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: largeText ? .8 : 1.35,
            child: ColoredBox(
              color: const Color(0xFFDCE1E7),
              child: widget.photos.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.pets_outlined,
                        size: 56,
                        color: Color(0xFF626975),
                        semanticLabel: 'Sin foto pública',
                      ),
                    )
                  : PageView(
                      key: ValueKey((widget.name, widget.photos.length)),
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
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xB3000000),
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: IgnorePointer(
              child: _CasePhotoCaption(
                name: widget.name,
                eventLabel: widget.eventLabel,
                photo: _photo,
                photoCount: widget.photos.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CasePhotoCaption extends StatelessWidget {
  const _CasePhotoCaption({
    required this.name,
    required this.eventLabel,
    required this.photo,
    required this.photoCount,
  });
  final String name, eventLabel;
  final int photo, photoCount;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const badgeStyle = TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
      final measure = TextPainter(
        text: TextSpan(text: eventLabel, style: badgeStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stack =
          MediaQuery.textScalerOf(context).scale(16) > 22 ||
          measure.width + 24 > constraints.maxWidth * .5;
      measure.dispose();
      final title = Text(
        name,
        key: const ValueKey('public-case-photo-name'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 48,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Color(0x33000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      );
      final badge = Container(
        key: const ValueKey('public-case-photo-status'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xD9C35C68),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(eventLabel, style: badgeStyle),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stack) ...[
            title,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: badge),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                badge,
              ],
            ),
          const SizedBox(height: 8),
          Center(
            child: photoCount <= 1
                ? const SizedBox(height: 6)
                : Semantics(
                    label: 'Foto ${photo + 1} de $photoCount',
                    child: Row(
                      key: const ValueKey('public-case-photo-pagination'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < photoCount; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == photo
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    },
  );
}
