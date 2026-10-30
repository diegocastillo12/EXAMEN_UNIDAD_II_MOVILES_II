import '../../../pets/domain/entities/pet.dart';
import '../entities/lost_case.dart';
import '../repositories/lost_case_repository.dart';

class PublishLostCase {
  const PublishLostCase(this._repository);
  final LostCaseRepository _repository;
  void validate(LostCaseDraft draft, DateTime now) {
    final errors = <CaseField>{};
    if (draft.petId.isEmpty || draft.petVersion < 1) errors.add(CaseField.pet);
    if (!draft.latitude.isFinite ||
        !draft.longitude.isFinite ||
        draft.latitude < -85 ||
        draft.latitude > 85 ||
        draft.longitude < -180 ||
        draft.longitude > 180) {
      errors.add(CaseField.point);
    }
    if (draft.occurredAt.isAfter(now) ||
        draft.occurredAt.isBefore(DateTime.utc(2000))) {
      errors.add(CaseField.date);
    }
    if (draft.placeReference.trim().isEmpty ||
        draft.placeReference.trim().runes.length > 120) {
      errors.add(CaseField.place);
    }
    if (draft.photoIds.isEmpty ||
        draft.photoIds.length > 3 ||
        draft.photoIds.toSet().length != draft.photoIds.length ||
        draft.photoIds.any((id) => id.isEmpty)) {
      errors.add(CaseField.photos);
    }
    if (draft.id.isEmpty || errors.isNotEmpty) {
      throw CaseFailure(
        CaseFailureKind.invalid,
        fields: Set.unmodifiable(errors),
      );
    }
  }

  Future<PublishedLostCase> call(String owner, LostCaseDraft draft) async {
    if (owner.isEmpty) throw const CaseFailure(CaseFailureKind.forbidden);
    validate(draft, DateTime.now());
    final result = await _repository.publish(owner, draft);
    if (result.id != draft.id ||
        result.ownerId != owner ||
        result.petId != draft.petId ||
        result.status != 'active') {
      throw const CaseFailure(CaseFailureKind.unavailable);
    }
    return result;
  }
}

void validateLostCasePet(Pet? pet) {
  if (pet != null && pet.activeCaseCount > 0) {
    throw const CaseFailure(CaseFailureKind.activeCase);
  }
}
