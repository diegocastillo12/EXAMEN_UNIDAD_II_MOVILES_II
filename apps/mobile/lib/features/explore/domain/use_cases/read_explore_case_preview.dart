import '../../../found_cases/domain/repositories/found_case_repository.dart';
import '../../../lost_cases/domain/repositories/lost_case_repository.dart';
import '../entities/explore_case_preview.dart';
import '../entities/explore_page.dart';
import '../failures/explore_failure.dart';

/// Reads only the public detail of the selected case, never the private pet.
class ReadExploreCasePreview {
  const ReadExploreCasePreview(this._lost, this._found);
  final LostCaseRepository _lost;
  final FoundCaseRepository _found;

  Future<ExploreCasePreview> call(ExploreCase item) async {
    try {
      if (item.fromPet) {
        final value = await _lost.readPublic(item.id);
        if (value == null || value.id != item.id) {
          throw const ExploreFailure(ExploreFailureKind.unavailable);
        }
        return ExploreCasePreview(
          occurredAt: value.occurredAt,
          size: value.fields.size?.name,
          photoUri: value.photos.isEmpty
              ? item.coverUri
              : value.photos.first.uri,
        );
      }
      final value = await _found.readPublic(item.id);
      if (value == null || value.id != item.id) {
        throw const ExploreFailure(ExploreFailureKind.unavailable);
      }
      return ExploreCasePreview(
        occurredAt: value.occurredAt,
        size: value.size,
        photoUri: value.photos.isEmpty ? item.coverUri : value.photos.first.uri,
      );
    } catch (_) {
      throw const ExploreFailure(ExploreFailureKind.unavailable);
    }
  }
}
