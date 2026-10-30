import '../../../lost_cases/domain/use_cases/read_lost_cases.dart';
import '../../../lost_cases/domain/use_cases/delete_lost_case.dart';
import '../entities/recovery_report.dart';
import '../entities/found_case.dart';
import 'found_case_actions.dart';
import 'delete_found_case.dart';

class ListRecoveryReports {
  const ListRecoveryReports(this._pets, this._community);
  final ListMyLostCases _pets;
  final ListMyFoundCases _community;
  Future<List<RecoveryReport>> call(String owner) async {
    final lists = await Future.wait<List<RecoveryReport>>([
      _pets(owner).then((rows) => rows.map(RecoveryReport.pet).toList()),
      _community(
        owner,
      ).then((rows) => rows.map(RecoveryReport.community).toList()),
    ]);
    // Both sources must succeed; a failed read must never look like an empty list.
    return List.unmodifiable(lists.expand((items) => items));
  }
}

class RemoveRecoveryReport {
  const RemoveRecoveryReport(this._pets, this._community, this._discard);
  final DeletePublishedLostCase _pets;
  final DeleteFoundPublication _community;
  final DiscardFoundDraft _discard;
  Future<void> call(String owner, RecoveryReport value) {
    if (value.fromPet) return _pets(owner, value.petCase!);
    if (value.report!.ownerId != owner) {
      throw const FoundFailure(FoundFailureKind.forbidden);
    }
    return value.pending
        ? _discard(owner, value.id)
        : _community(owner, value.report!);
  }
}
