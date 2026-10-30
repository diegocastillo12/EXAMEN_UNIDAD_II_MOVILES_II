/// Account-scoped choices. Version zero means no persisted configuration yet.
class AlertPreferences {
  const AlertPreferences({
    required this.ownerId,
    this.version = 0,
    this.enabled = false,
    this.lostPets = true,
    this.foundPets = true,
    this.caseUpdates = true,
    this.inApp = true,
    this.push = false,
  });
  final String ownerId;
  final int version;
  final bool enabled;
  final bool lostPets;
  final bool foundPets;
  final bool caseUpdates;
  final bool inApp;
  final bool push;

  bool sameChoices(AlertPreferences other) =>
      enabled == other.enabled &&
      lostPets == other.lostPets &&
      foundPets == other.foundPets &&
      caseUpdates == other.caseUpdates &&
      inApp == other.inApp &&
      push == other.push;

  AlertPreferences copyWith({
    int? version,
    bool? enabled,
    bool? lostPets,
    bool? foundPets,
    bool? caseUpdates,
    bool? inApp,
    bool? push,
  }) => AlertPreferences(
    ownerId: ownerId,
    version: version ?? this.version,
    enabled: enabled ?? this.enabled,
    lostPets: lostPets ?? this.lostPets,
    foundPets: foundPets ?? this.foundPets,
    caseUpdates: caseUpdates ?? this.caseUpdates,
    inApp: inApp ?? this.inApp,
    push: push ?? this.push,
  );
}
