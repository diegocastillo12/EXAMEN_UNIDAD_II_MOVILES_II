import '../../domain/entities/case_closure.dart';
import '../../domain/repositories/case_closure_repository.dart';
import '../data_sources/case_closure_source.dart';
import '../models/case_closure_dto.dart';

class CaseClosureRepositoryImpl implements CaseClosureRepository {
  const CaseClosureRepositoryImpl(this.source);
  final CaseClosureSource source;
  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on ClosureSourceFailure catch (e) {
      throw ClosureFailure(switch (e.code) {
        'invalid' => ClosureIssue.invalid,
        'forbidden' => ClosureIssue.forbidden,
        'conflict' => ClosureIssue.conflict,
        'closed' => ClosureIssue.closed,
        _ => ClosureIssue.unavailable,
      });
    } on ClosureFailure {
      rethrow;
    } catch (_) {
      throw const ClosureFailure(ClosureIssue.unavailable);
    }
  }

  Map<String, dynamic> _target(ClosureTarget target) => {
    'p_source': target.community ? 'found' : 'lost',
    'p_case': target.id,
  };
  @override
  Future<ClosureDetail> read(String owner, ClosureTarget target) =>
      _run(() async {
        final detail = CaseClosureDto.detail(
          await source.call(owner, 'read_case_closure', _target(target)),
        );
        if (detail.receipt != null &&
            (detail.receipt!.actor != owner ||
                detail.receipt!.target != target)) {
          throw const FormatException();
        }
        return detail;
      });
  @override
  Future<ClosureReceipt> close(String owner, ClosureCommand command) =>
      _run(() async {
        final receipt = CaseClosureDto.receipt(
          await source.call(owner, 'close_recovery_case', {
            ..._target(command.target),
            'p_command': command.id,
            'p_reason': command.reason.trim(),
            'p_evidence_note': command.evidence.trim().isEmpty
                ? null
                : command.evidence.trim(),
          }),
        );
        if (receipt.commandId != command.id ||
            receipt.target != command.target ||
            receipt.actor != owner ||
            receipt.reason != command.reason.trim() ||
            (receipt.evidence ?? '') != command.evidence.trim()) {
          throw const FormatException();
        }
        return receipt;
      });
}

class UnavailableCaseClosureRepository implements CaseClosureRepository {
  const UnavailableCaseClosureRepository();
  @override
  Future<ClosureDetail> read(String owner, ClosureTarget target) async =>
      throw const ClosureFailure(ClosureIssue.unavailable);
  @override
  Future<ClosureReceipt> close(String owner, ClosureCommand command) async =>
      throw const ClosureFailure(ClosureIssue.unavailable);
}
