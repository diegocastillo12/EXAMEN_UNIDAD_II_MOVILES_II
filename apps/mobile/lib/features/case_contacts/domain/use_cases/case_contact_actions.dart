import '../entities/case_contact.dart';
import '../repositories/case_contact_repository.dart';

class ReadCaseContact {
  const ReadCaseContact(this._repository);
  final CaseContactRepository _repository;
  Future<CaseContactAccess> call(String owner, CaseContactTarget target) =>
      _repository.read(owner, target);
}

class SaveCaseContact {
  const SaveCaseContact(this._repository);
  final CaseContactRepository _repository;
  Future<CaseContactAccess> call(
    String owner,
    CaseContactTarget target,
    CaseContactDraft draft,
  ) {
    final name = draft.name.trim();
    final phone = draft.phone.replaceAll(RegExp(r'[\s()-]'), '');
    if (draft.version < 0 ||
        (draft.enabled &&
            (name.runes.length < 2 ||
                name.runes.length > 80 ||
                RegExp(r'[\x00-\x1f\x7f]').hasMatch(name) ||
                !RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone)))) {
      throw const CaseContactFailure(CaseContactFailureKind.invalid);
    }
    return _repository.save(
      owner,
      target,
      CaseContactDraft(
        enabled: draft.enabled,
        name: draft.enabled ? name : '',
        phone: draft.enabled ? phone : '',
        sharePhoto: draft.enabled && draft.sharePhoto,
        version: draft.version,
      ),
    );
  }
}

class OpenCaseContact {
  const OpenCaseContact(this._repository);
  final CaseContactRepository _repository;
  Future<void> call(String phone, {required bool message}) {
    if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone)) {
      throw const CaseContactFailure(CaseContactFailureKind.invalid);
    }
    return _repository.open(phone, message: message);
  }
}
