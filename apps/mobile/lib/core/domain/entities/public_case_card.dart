enum PublicCaseKind { all, lost, found, sighting }

enum PublicCaseStatus { all, active, resolved }

class PublicCaseCard {
  const PublicCaseCard({
    required this.id,
    this.reportKind = 'own_loss',
    required this.fromPet,
    required this.kind,
    required this.status,
    required this.species,
    required this.name,
    required this.traits,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.coverUri,
  });
  final String id, species, name, traits, reportKind;
  final bool fromPet;
  final PublicCaseKind kind;
  final PublicCaseStatus status;
  final DateTime occurredAt;
  final double latitude, longitude;
  final int? distanceMeters;
  final Uri? coverUri;
  String get key => '${fromPet ? 'lost' : 'found'}:$id';
}
