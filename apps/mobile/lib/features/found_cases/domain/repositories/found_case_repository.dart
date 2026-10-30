import 'dart:typed_data';
import '../entities/found_case.dart';

abstract interface class FoundCaseRepository {
  Future<Uint8List?> choosePhoto(
    String owner,
    String draftId, {
    bool camera = false,
  });
  Future<Uint8List?> recoverPhoto(String owner, String draftId);
  Future<FoundPublication> publish(String owner, FoundCaseDraft draft);
  Future<PublicFoundCase?> readPublic(String id);
  Future<List<FoundPublication>> listMine(String owner);
  Future<void> discard(String owner, String id);
  Future<List<PublicFoundCase>> listObservations(String id, bool community);
  Future<List<RecoverySearch>> listOpenSearches(String owner);
  Future<void> resolveSearch(String owner, String id, bool community);
  Future<void> delete(String owner, String id);
}
