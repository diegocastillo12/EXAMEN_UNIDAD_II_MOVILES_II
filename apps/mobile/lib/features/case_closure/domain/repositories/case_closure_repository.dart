import '../entities/case_closure.dart';

abstract interface class CaseClosureRepository {
  Future<ClosureDetail> read(String owner, ClosureTarget target);
  Future<ClosureReceipt> close(String owner, ClosureCommand command);
}
