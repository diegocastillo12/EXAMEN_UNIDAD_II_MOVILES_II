import '../../domain/entities/lost_case.dart';
import '../models/lost_case_dto.dart';

abstract interface class LostCaseDataSource {
  Future<LostCaseDto> publish(String owner, LostCaseDraft draft);
  Future<LostCaseDto?> readPublic(String id);
  Future<List<LostCaseDto>> listMine(String owner);
  Future<Uri?> photoUri(String path);
  Future<void> delete(String owner, String id);
}

class CaseSourceFailure implements Exception {
  const CaseSourceFailure(this.kind);
  final CaseFailureKind kind;
}
