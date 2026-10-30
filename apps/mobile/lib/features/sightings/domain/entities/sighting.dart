import 'dart:typed_data';

enum SightingIssue {
  localStorage,
  invalid,
  unavailable,
  forbidden,
  blocked,
  closed,
  conflict,
  rateLimited,
  photo,
  location,
}

class SightingFailure implements Exception {
  const SightingFailure(this.issue, [this.fields = const {}]);
  final SightingIssue issue;
  final Set<String> fields;
}

class SightingTarget {
  const SightingTarget(this.id, this.community);
  final String id;
  final bool community;
}

class SightingPoint {
  const SightingPoint(this.latitude, this.longitude, {this.accuracy});
  final double latitude, longitude;
  final double? accuracy;
  String get source => accuracy == null ? 'manual' : 'gps';
}

class SightingDraft {
  SightingDraft({
    required this.id,
    required this.target,
    required this.observedAt,
    required this.point,
    required this.comment,
    Uint8List? photo,
  }) : photo = photo == null
           ? null
           : Uint8List.fromList(photo).asUnmodifiableView();
  final String id, comment;
  final SightingTarget target;
  final DateTime observedAt;
  final SightingPoint point;
  final Uint8List? photo;
}

class SightingReceipt {
  const SightingReceipt(this.id, this.receivedAt, this.late);
  final String id;
  final DateTime receivedAt;
  final bool late;
}
