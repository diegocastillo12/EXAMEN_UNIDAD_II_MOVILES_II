import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/immersive_photo_sheet.dart';
import '../../../../core/presentation/widgets/case_public_cards.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/found_case.dart';

String foundSpeciesLabel(String? species) => switch (species) {
  'dog' => 'Perro',
  'cat' => 'Gato',
  'other' => 'Otra especie',
  _ => 'Mascota',
};
String foundDateLabel(DateTime time) => caseDateTimeLabel(time);

class FoundPublicContent extends StatelessWidget {
  const FoundPublicContent({
    required this.value,
    this.actions,
    this.contact,
    this.offline = false,
    this.localPhotos = const {},
    super.key,
  });
  final PublicFoundCase value;
  final Widget? actions;
  final Widget? contact;
  final bool offline;
  final Map<String, Uint8List> localPhotos;
  @override
  Widget build(BuildContext context) => CasePublicCards(
    key: ValueKey(value.id),
    offline: offline,
    name: value.speciesDetail ?? foundSpeciesLabel(value.species),
    eventLabel: value.status != 'active'
        ? 'Reporte cerrado'
        : switch (value.reportKind) {
            'possible_loss' => 'Posiblemente perdida',
            'sighting' => 'Avistamiento',
            'independent_found' || 'with_reporter' => 'Encontrada',
            _ => 'Reporte anterior',
          },
    photos: [
      for (final photo in value.photos)
        localPhotos[photo.id] != null
            ? CasePhotoView.memory(localPhotos[photo.id]!)
            : photo.uri == null
            ? const CasePhotoFailure()
            : CasePhotoView.network(photo.uri!),
    ],
    facts: [
      CasePublicFact('Especie', foundSpeciesLabel(value.species)),
      if (value.sex != null)
        CasePublicFact('Sexo', value.sex == 'male' ? 'Macho' : 'Hembra'),
      if (value.size != null)
        CasePublicFact('Tamaño', switch (value.size!) {
          'small' => 'Pequeño',
          'medium' => 'Mediano',
          _ => 'Grande',
        }),
      if (value.custody != null)
        CasePublicFact(
          'Cuidado',
          value.custody == 'with_me'
              ? 'Está bajo mi cuidado'
              : 'No está bajo mi cuidado',
        ),
    ],
    description: value.traits,
    occurredAt: 'Observada el ${foundDateLabel(value.occurredAt)}',
    locationLabel: value.reportKind == 'possible_loss'
        ? 'Ubicación de posible desaparición'
        : 'Ubicación del aviso',
    latitude: value.latitude,
    longitude: value.longitude,
    privacy:
        'Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados.',
    actions: actions,
    contact: value.status == 'active' ? contact : null,
  );
}

class FoundPreviewContent extends StatelessWidget {
  const FoundPreviewContent({
    required this.value,
    required this.localPhotos,
    this.actions,
    this.isPreview = true,
    super.key,
  });
  final PublicFoundCase value;
  final Map<String, Uint8List> localPhotos;
  final Widget? actions;
  final bool isPreview;
  @override
  Widget build(BuildContext context) => ImmersivePhotoSheet(
    name: value.speciesDetail ?? foundSpeciesLabel(value.species),
    latitude: value.latitude,
    longitude: value.longitude,
    locationLabel: value.reportKind == 'possible_loss'
        ? 'Ubicación de posible desaparición'
        : 'Ubicación del aviso',
    photos: [
      for (final photo in value.photos)
        localPhotos[photo.id] != null
            ? CasePhotoView.memory(localPhotos[photo.id]!)
            : photo.uri == null
            ? const CasePhotoFailure()
            : CasePhotoView.network(photo.uri!),
    ],
    facts: [
      if (!isPreview && value.status == 'active')
        const PreviewFact(Icons.search, 'Reporte activo'),
      PreviewFact(Icons.pets_outlined, foundSpeciesLabel(value.species)),
      if (value.size != null)
        PreviewFact(Icons.straighten, switch (value.size!) {
          'small' => 'Pequeño',
          'medium' => 'Mediano',
          _ => 'Grande',
        }),
      if (value.sex != null)
        PreviewFact(
          value.sex == 'male' ? Icons.male : Icons.female,
          value.sex == 'male' ? 'Macho' : 'Hembra',
        ),
      if (value.custody != null)
        PreviewFact(
          Icons.home_outlined,
          value.custody == 'with_me'
              ? 'Está bajo mi cuidado'
              : 'No está bajo mi cuidado',
        ),
    ],
    description: value.traits,
    eventLabel: switch (value.reportKind) {
      'possible_loss' => 'Posiblemente perdida',
      'sighting' => 'Avistamiento',
      'independent_found' || 'with_reporter' => 'Encontrada',
      _ => 'Reporte anterior',
    },
    occurredAt: 'Observada el ${foundDateLabel(value.occurredAt)}',
    privacy: isPreview
        ? 'Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados. Al publicar, estos datos y fotos serán públicos; revisa que no contengan domicilio, documentos ni datos personales.'
        : 'Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados.',
    actions: actions,
  );
}
