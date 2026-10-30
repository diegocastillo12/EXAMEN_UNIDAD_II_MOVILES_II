enum MatchIssue { invalid, forbidden, conflict, unavailable, busy }

class MatchFailure implements Exception {
  const MatchFailure(this.kind);
  final MatchIssue kind;
}

class MatchReference {
  const MatchReference(this.source, this.id);
  final String source, id;
  String get key => '$source:$id';
}

class MatchSearch {
  const MatchSearch(this.reference, this.name, this.species);
  final MatchReference reference;
  final String name, species;
}

class CaseMatchCandidate {
  const CaseMatchCandidate({
    required this.reference,
    required this.revision,
    required this.name,
    required this.distanceMeters,
    required this.daysApart,
    this.review,
  });
  final MatchReference reference;
  final String revision, name;
  final int distanceMeters, daysApart;
  final String? review;
  CaseMatchCandidate reviewed(String decision) => CaseMatchCandidate(
    reference: reference,
    revision: revision,
    name: name,
    distanceMeters: distanceMeters,
    daysApart: daysApart,
    review: decision,
  );
}

class CaseMatchResult {
  CaseMatchResult({
    required this.anchor,
    required this.revision,
    required this.model,
    required List<CaseMatchCandidate> candidates,
    required this.pendingPhotos,
    required this.complete,
  }) : candidates = List.unmodifiable(candidates);
  final MatchReference anchor;
  final String revision, model;
  final List<CaseMatchCandidate> candidates;
  final int pendingPhotos;
  final bool complete;
  CaseMatchResult reviewed(String key, String decision) => CaseMatchResult(
    anchor: anchor,
    revision: revision,
    model: model,
    candidates: [
      for (final c in candidates)
        c.reference.key == key ? c.reviewed(decision) : c,
    ],
    pendingPhotos: pendingPhotos,
    complete: complete,
  );
}

class MatchReviewCommand {
  const MatchReviewCommand({
    required this.id,
    required this.result,
    required this.candidate,
    required this.decision,
  });
  final String id, decision;
  final CaseMatchResult result;
  final CaseMatchCandidate candidate;
}
