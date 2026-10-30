import '../../domain/entities/lost_case.dart';
import '../../domain/repositories/lost_case_repository.dart';

class UnavailableLostCaseRepository implements LostCaseRepository {
  const UnavailableLostCaseRepository();
  @override
  Future<PublishedLostCase> publish(String owner, LostCaseDraft draft) async =>
      throw const CaseFailure(CaseFailureKind.unavailable);
  @override
  Future<List<PublishedLostCase>> listMine(String owner) async =>
      throw const CaseFailure(CaseFailureKind.unavailable);
  @override
  Future<PublicLostCase?> readPublic(String id) async =>
      throw const CaseFailure(CaseFailureKind.unavailable);
  @override
  Future<void> delete(String owner, String id) async =>
      throw const CaseFailure(CaseFailureKind.unavailable);
}
