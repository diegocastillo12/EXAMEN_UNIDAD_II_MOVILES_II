import '../entities/case_closure.dart';
import '../repositories/case_closure_repository.dart';

class ReadCaseClosure {
  const ReadCaseClosure(this.repository);
  final CaseClosureRepository repository;
  Future<ClosureDetail> call(String owner, ClosureTarget target) {
    if (owner.isEmpty || target.id.isEmpty) {
      throw const ClosureFailure(ClosureIssue.forbidden);
    }
    return repository.read(owner, target);
  }
}

class CloseRecoveryCase {
  const CloseRecoveryCase(this.repository);
  final CaseClosureRepository repository;
  void validate(String reason, String evidence) {
    if (reason.trim().isEmpty ||
        reason.trim().runes.length > 500 ||
        evidence.trim().runes.length > 500) {
      throw const ClosureFailure(ClosureIssue.invalid);
    }
  }

  Future<ClosureReceipt> call(String owner, ClosureCommand command) {
    if (owner.isEmpty) throw const ClosureFailure(ClosureIssue.forbidden);
    if (command.id.isEmpty || command.target.id.isEmpty) {
      throw const ClosureFailure(ClosureIssue.invalid);
    }
    validate(command.reason, command.evidence);
    return repository.close(owner, command);
  }
}
