import '../entities/lost_case.dart';

abstract interface class LostCaseRepository {
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft);
  Future<PublicLostCase?> readPublic(String id);
  Future<List<PublishedLostCase>> listMine(String owner);
  Future<void> delete(String owner, String id);
}
