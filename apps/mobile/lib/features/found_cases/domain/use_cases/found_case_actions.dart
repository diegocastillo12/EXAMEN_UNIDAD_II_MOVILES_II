import 'dart:typed_data';
import '../entities/found_case.dart';
import '../repositories/found_case_repository.dart';

class PublishFoundCase {
  const PublishFoundCase(this._repository);
  final FoundCaseRepository _repository;
  void validate(FoundCaseDraft d, DateTime now) {
    final fields = <FoundField>{};
    if (!{
          'possible_loss',
          'independent_found',
          'sighting',
          'with_reporter',
        }.contains(d.reportKind) ||
        ({'possible_loss', 'independent_found'}.contains(d.reportKind) &&
            (d.targetId != null || d.communityTarget)) ||
        (!{'possible_loss', 'independent_found'}.contains(d.reportKind) &&
            (d.targetId == null ||
                d.targetId!.isEmpty ||
                d.targetId == d.id))) {
      fields.add(FoundField.target);
    }
    if ({'possible_loss', 'independent_found'}.contains(d.reportKind) &&
        (!{'dog', 'cat', 'other'}.contains(d.species) ||
            (d.species == 'other' &&
                (d.speciesDetail == null ||
                    d.speciesDetail!.trim().isEmpty ||
                    d.speciesDetail!.trim().runes.length > 40)) ||
            (d.species != 'other' && d.speciesDetail != null))) {
      fields.add(FoundField.species);
    }
    if (d.traits.trim().isEmpty || d.traits.trim().runes.length > 200) {
      fields.add(FoundField.traits);
    }
    if (d.occurredAt.isAfter(now) ||
        d.occurredAt.isBefore(DateTime.utc(2000))) {
      fields.add(FoundField.date);
    }
    if (!d.latitude.isFinite ||
        !d.longitude.isFinite ||
        d.latitude.abs() > 85 ||
        d.longitude.abs() > 180) {
      fields.add(FoundField.point);
    }
    if (d.placeReference.trim().isEmpty ||
        d.placeReference.trim().runes.length > 120) {
      fields.add(FoundField.place);
    }
    if (({'possible_loss', 'independent_found'}.contains(d.reportKind) &&
            d.photos.isEmpty) ||
        d.photos.length > 3 ||
        d.photos.map((p) => p.id).toSet().length != d.photos.length ||
        d.photos.any(
          (p) =>
              p.id.isEmpty ||
              p.bytes.length < 4 ||
              p.bytes.length > 2097152 ||
              p.bytes[0] != 255 ||
              p.bytes[1] != 216 ||
              p.bytes[2] != 255,
        )) {
      fields.add(FoundField.photos);
    }
    if (fields.isNotEmpty ||
        d.id.isEmpty ||
        (d.size != null && !{'small', 'medium', 'large'}.contains(d.size)) ||
        (d.sex != null && !{'male', 'female'}.contains(d.sex)) ||
        (d.custody != null &&
            !{'with_me', 'not_with_me'}.contains(d.custody))) {
      throw FoundFailure(FoundFailureKind.invalid, fields: fields);
    }
  }

  Future<FoundPublication> call(String owner, FoundCaseDraft draft) async {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    validate(draft, DateTime.now());
    final result = await _repository.publish(owner, draft);
    if (result.id != draft.id ||
        result.ownerId != owner ||
        result.status != 'active' ||
        result.reportKind != draft.reportKind ||
        result.targetId != draft.targetId ||
        result.communityTarget != draft.communityTarget) {
      throw const FoundFailure(FoundFailureKind.unavailable);
    }
    return result;
  }
}

class ChooseFoundPhoto {
  const ChooseFoundPhoto(this._repository);
  final FoundCaseRepository _repository;
  Future<Uint8List?> call(String owner, String draft, {bool camera = false}) {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    return _repository.choosePhoto(owner, draft, camera: camera);
  }

  Future<Uint8List?> recover(String owner, String draft) {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    return _repository.recoverPhoto(owner, draft);
  }
}

class ReadPublicFoundCase {
  const ReadPublicFoundCase(this._repository);
  final FoundCaseRepository _repository;
  Future<PublicFoundCase?> call(String id) => _repository.readPublic(id);
}

class ListMyFoundCases {
  const ListMyFoundCases(this._repository);
  final FoundCaseRepository _repository;
  Future<List<FoundPublication>> call(String owner) async {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    final rows = await _repository.listMine(owner);
    if (rows.any((r) => r.ownerId != owner)) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    return rows;
  }
}

class DiscardFoundDraft {
  const DiscardFoundDraft(this._repository);
  final FoundCaseRepository _repository;
  Future<void> call(String owner, String id) {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    return _repository.discard(owner, id);
  }
}

class ListOpenRecoverySearches {
  const ListOpenRecoverySearches(this.repository);
  final FoundCaseRepository repository;
  Future<List<RecoverySearch>> call(String owner) {
    if (owner.isEmpty) throw const FoundFailure(FoundFailureKind.forbidden);
    return repository.listOpenSearches(owner);
  }
}

class ResolveRecoverySearch {
  const ResolveRecoverySearch(this.repository);
  final FoundCaseRepository repository;
  Future<void> call(String owner, String id, bool community) {
    if (owner.isEmpty || id.isEmpty) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    return repository.resolveSearch(owner, id, community);
  }
}

class ReadRecoveryObservations {
  const ReadRecoveryObservations(this.repository);
  final FoundCaseRepository repository;
  Future<List<PublicFoundCase>> call(String id, bool community) =>
      repository.listObservations(id, community);
}
