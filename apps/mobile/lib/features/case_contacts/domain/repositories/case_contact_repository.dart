import '../entities/case_contact.dart';

abstract interface class CaseContactRepository {
  Future<CaseContactAccess> read(String owner, CaseContactTarget target);
  Future<CaseContactAccess> save(
    String owner,
    CaseContactTarget target,
    CaseContactDraft draft,
  );
  Future<void> open(String phone, {required bool message});
}
