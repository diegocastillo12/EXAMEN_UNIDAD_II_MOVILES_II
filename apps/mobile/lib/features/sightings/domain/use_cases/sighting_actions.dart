import 'dart:typed_data';
import '../entities/sighting.dart';
import '../repositories/sighting_repository.dart';

class SubmitSighting {
  const SubmitSighting(this.repository);
  final SightingRepository repository;
  void validate(String owner, SightingDraft draft) {
    if (owner.isEmpty) throw const SightingFailure(SightingIssue.forbidden);
    final fields = <String>{};
    if (draft.observedAt.isAfter(DateTime.now()) ||
        draft.observedAt.isBefore(DateTime.utc(2000))) {
      fields.add('observedAt');
    }
    final p = draft.point;
    if (!p.latitude.isFinite ||
        p.latitude.abs() > 85 ||
        !p.longitude.isFinite ||
        p.longitude.abs() > 180 ||
        (p.accuracy != null &&
            (!p.accuracy!.isFinite ||
                p.accuracy! < 0 ||
                p.accuracy! > 100000))) {
      fields.add('point');
    }
    if (draft.comment.trim().runes.length > 500) fields.add('comment');
    if (draft.photo != null &&
        (draft.photo!.isEmpty || draft.photo!.length > 8388608)) {
      fields.add('photo');
    }
    if (draft.target.id.isEmpty || draft.id.isEmpty) fields.add('id');
    if (fields.isNotEmpty) throw SightingFailure(SightingIssue.invalid, fields);
  }

  Future<SightingReceipt> call(String owner, SightingDraft draft) async {
    validate(owner, draft);
    final receipt = await repository.submit(owner, draft);
    if (receipt.id != draft.id) {
      throw const SightingFailure(SightingIssue.unavailable);
    }
    return receipt;
  }
}

class LocateSighting {
  const LocateSighting(this.repository);
  final SightingRepository repository;
  Future<SightingPoint> call() async {
    final p = await repository.locate();
    if (!p.latitude.isFinite ||
        p.latitude.abs() > 85 ||
        !p.longitude.isFinite ||
        p.longitude.abs() > 180 ||
        p.accuracy == null ||
        !p.accuracy!.isFinite ||
        p.accuracy! < 0 ||
        p.accuracy! > 100000) {
      throw const SightingFailure(SightingIssue.location);
    }
    return p;
  }
}

class ChooseSightingPhoto {
  const ChooseSightingPhoto(this.repository);
  final SightingRepository repository;
  Future<Uint8List?> call({bool camera = false}) =>
      repository.choosePhoto(camera: camera);
}
