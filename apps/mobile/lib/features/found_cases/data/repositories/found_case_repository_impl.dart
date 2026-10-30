import 'dart:typed_data';
import '../../../../core/data_sources/photo_gallery_source.dart';
import '../../domain/entities/found_case.dart';
import '../../domain/repositories/found_case_repository.dart';
import '../data_sources/found_case_data_source.dart';

class FoundCaseRepositoryImpl implements FoundCaseRepository {
  const FoundCaseRepositoryImpl(this._source, this._gallery);
  final FoundCaseDataSource _source;
  final PhotoGallerySource _gallery;
  Future<T> _run<T>(Future<T> Function() work) async {
    try {
      return await work();
    } on FoundSourceFailure catch (e) {
      throw FoundFailure(e.kind);
    } on PhotoGalleryFailure catch (e) {
      throw FoundFailure(
        e.kind == PhotoGalleryFailureKind.invalidPhoto
            ? FoundFailureKind.photoInvalid
            : FoundFailureKind.gallery,
      );
    } catch (_) {
      throw const FoundFailure(FoundFailureKind.unavailable);
    }
  }

  @override
  Future<Uint8List?> choosePhoto(
    String owner,
    String id, {
    bool camera = false,
  }) => _run(() => _gallery.choose(owner, id, false, camera: camera));
  @override
  Future<Uint8List?> recoverPhoto(String owner, String id) =>
      _run(() => _gallery.recover(owner, id, false));
  @override
  Future<FoundPublication> publish(String owner, FoundCaseDraft d) =>
      _run(() async => (await _source.publish(owner, d)).publication());
  @override
  Future<PublicFoundCase?> readPublic(String id) => _run(() async {
    final dto = await _source.readPublic(id);
    if (dto == null) return null;
    final photos = await Future.wait(
      (dto.row['photos'] as List).map(
        (p) async => FoundPhoto(
          p['id'] as String,
          await _source.photoUri(p['path'] as String),
        ),
      ),
    );
    return dto.publicCase(photos);
  });
  @override
  Future<List<FoundPublication>> listMine(String owner) => _run(
    () async => Future.wait(
      (await _source.listMine(owner)).map(
        (d) async => d.publication(
          coverUri: d.row['cover_path'] == null
              ? null
              : await _source.photoUri(d.row['cover_path'] as String),
        ),
      ),
    ),
  );
  @override
  Future<void> discard(String owner, String id) =>
      _run(() => _source.discard(owner, id));
  @override
  Future<List<PublicFoundCase>> listObservations(String id, bool community) =>
      _run(
        () async => Future.wait(
          (await _source.listObservations(id, community)).map(
            (dto) async => dto.publicCase(
              await Future.wait(
                (dto.row['photos'] as List).map(
                  (photo) async => FoundPhoto(
                    photo['id'] as String,
                    await _source.photoUri(photo['path'] as String),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  @override
  Future<List<RecoverySearch>> listOpenSearches(String owner) => _run(
    () async => (await _source.listOpenSearches(owner))
        .map(
          (row) => RecoverySearch(
            id: row['id'] as String,
            community: row['community'] as bool,
            name: row['name'] as String,
            species: row['species'] as String,
            speciesDetail: row['species_detail'] as String?,
            size: row['size'] as String?,
            sex: row['sex'] as String?,
          ),
        )
        .toList(),
  );
  @override
  Future<void> resolveSearch(String owner, String id, bool community) =>
      _run(() => _source.resolveSearch(owner, id, community));
  @override
  Future<void> delete(String owner, String id) =>
      _run(() => _source.delete(owner, id));
}
