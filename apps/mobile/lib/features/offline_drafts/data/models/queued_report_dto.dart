import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/entities/local_report_draft.dart';
import '../../domain/entities/queued_report.dart';
import '../../../lost_cases/domain/entities/lost_case.dart';
import '../../../found_cases/domain/entities/found_case.dart';
import '../../../sightings/domain/entities/sighting.dart';
import 'local_report_draft_dto.dart';

class QueuedReportDto {
  static bool receiptMatches(LocalReportDraft d, SubmissionReceipt r) {
    if (r.id != d.id) {
      return false;
    }
    if (d.slot == 'lost') {
      return r.lost != null &&
          r.lost!.ownerId == d.owner &&
          r.lost!.petId == d.pet?.id &&
          r.lost!.status == 'active';
    }
    if (d.slot.startsWith('sighting:')) {
      return r.sighting != null;
    }
    final f = r.found, p = d.slot.split(':');
    if (f == null ||
        f.ownerId != d.owner ||
        f.status != 'active' ||
        f.reportKind != d.reportKind) {
      return false;
    }
    if ({'community-search', 'independent-found'}.contains(d.slot)) {
      return f.targetId == null && !f.communityTarget;
    }
    return p.length == 3 &&
        p[0] == 'found' &&
        f.targetId == p[2] &&
        f.communityTarget == (p[1] == 'true');
  }

  /// Fingerprint only the actual command, not UI/snapshot metadata or signed URLs.
  static String fingerprint(LocalReportDraft d) {
    final command = <String, Object?>{
      'owner': d.owner,
      'slot': d.slot,
      'id': d.id,
      'instant': d.instant?.toUtc().toIso8601String(),
      'lat': d.latitude,
      'lng': d.longitude,
      if (d.slot == 'lost') ...{
        'pet': d.pet?.id,
        'version': d.pet?.version,
        'place': d.place.trim(),
        'photos': d.selectedPhotos,
      } else if (d.slot.startsWith('sighting:')) ...{
        'accuracy': d.accuracy,
        'comment': d.comment,
        'photo': d.photo == null ? null : sha256.convert(d.photo!).toString(),
      } else ...{
        'kind': d.reportKind,
        'place': d.place.trim(),
        'species': d.species,
        'detail': d.species == 'other' ? d.speciesDetail.trim() : null,
        'size': d.size,
        'sex': d.sex,
        'traits': d.traits.trim(),
        'custody': d.custody,
        'photos': d.photos
            .map(
              (p) => {'id': p.id, 'hash': sha256.convert(p.bytes).toString()},
            )
            .toList(),
      },
    };
    return sha256.convert(utf8.encode(jsonEncode(command))).toString();
  }

  static String withoutEvidence(String payload) {
    final row = jsonDecode(payload) as Map<String, dynamic>;
    row['photos'] = [];
    row['photo'] = null;
    return jsonEncode(row);
  }

  static String encodeReceipt(SubmissionReceipt receipt) {
    final l = receipt.lost, f = receipt.found, s = receipt.sighting;
    return jsonEncode(
      l != null
          ? {
              'kind': 'lost',
              'id': l.id,
              'owner': l.ownerId,
              'pet': l.petId,
              'status': l.status,
              'name': l.petName,
            }
          : f != null
          ? {
              'kind': 'found',
              'id': f.id,
              'owner': f.ownerId,
              'status': f.status,
              'reportKind': f.reportKind,
              'target': f.targetId,
              'community': f.communityTarget,
              'species': f.species,
            }
          : {
              'kind': 'sighting',
              'id': s!.id,
              'received': s.receivedAt.toUtc().toIso8601String(),
              'late': s.late,
            },
    );
  }

  static SubmissionReceipt decodeReceipt(String value) {
    final r = jsonDecode(value) as Map<String, dynamic>;
    return switch (r['kind']) {
      'lost' => SubmissionReceipt.lost(
        PublishedLostCase(
          id: r['id'] as String,
          ownerId: r['owner'] as String,
          petId: r['pet'] as String,
          status: r['status'] as String,
          petName: r['name'] as String,
        ),
      ),
      'found' => SubmissionReceipt.found(
        FoundPublication(
          id: r['id'] as String,
          ownerId: r['owner'] as String,
          status: r['status'] as String,
          reportKind: r['reportKind'] as String,
          targetId: r['target'] as String?,
          communityTarget: r['community'] as bool,
          species: r['species'] as String?,
        ),
      ),
      'sighting' => SubmissionReceipt.sighting(
        SightingReceipt(
          r['id'] as String,
          DateTime.parse(r['received'] as String),
          r['late'] as bool,
        ),
      ),
      _ => throw const FormatException('Unknown receipt'),
    };
  }

  static QueuedReport decode(Map<String, dynamic> row) {
    final command = LocalReportDraftDto.decode(row['payload'] as String);
    if (command.owner != row['owner'] || command.id != row['id']) {
      throw const LocalDraftFailure();
    }
    final status = SubmissionStatus.values.byName(row['state'] as String);
    final receipt = row['receipt'] == null
        ? null
        : decodeReceipt(row['receipt'] as String);
    if ((status == SubmissionStatus.published) != (receipt != null) ||
        (receipt != null && !receiptMatches(command, receipt))) {
      throw const LocalDraftFailure();
    }
    return QueuedReport(
      command: command,
      status: status,
      attempts: row['attempts'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['created_at'] as int,
        isUtc: true,
      ),
      nextAttemptAt: DateTime.fromMillisecondsSinceEpoch(
        row['next_attempt_at'] as int,
        isUtc: true,
      ),
      issue: row['issue'] == null
          ? null
          : SubmissionIssue.values.byName(row['issue'] as String),
      receipt: receipt,
      claim: row['claim'] as String?,
    );
  }
}
