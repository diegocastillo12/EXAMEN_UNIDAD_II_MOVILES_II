import 'dart:typed_data';
import '../../domain/entities/found_case.dart';
import '../../domain/repositories/found_case_repository.dart';

class UnavailableFoundCaseRepository implements FoundCaseRepository {
  const UnavailableFoundCaseRepository();
  Never _fail() => throw const FoundFailure(FoundFailureKind.unavailable);
  @override
  Future<Uint8List?> choosePhoto(
    String owner,
    String id, {
    bool camera = false,
  }) async => _fail();
  @override
  Future<Uint8List?> recoverPhoto(String owner, String id) async => _fail();
  @override
  Future<FoundPublication> publish(String owner, FoundCaseDraft d) async =>
      _fail();
  @override
  Future<PublicFoundCase?> readPublic(String id) async => _fail();
  @override
  Future<List<FoundPublication>> listMine(String owner) async => _fail();
  @override
  Future<void> discard(String owner, String id) async => _fail();
  @override
  Future<List<PublicFoundCase>> listObservations(
    String id,
    bool community,
  ) async => _fail();
  @override
  Future<List<RecoverySearch>> listOpenSearches(String owner) async => _fail();
  @override
  Future<void> resolveSearch(String owner, String id, bool community) async =>
      _fail();
  @override
  Future<void> delete(String owner, String id) async =>
      throw const FoundFailure(FoundFailureKind.unavailable);
}
