import '../../domain/entities/case_contact.dart';
import '../../domain/repositories/case_contact_repository.dart';
import '../data_sources/case_contact_source.dart';
import '../models/case_contact_dto.dart';

class CaseContactRepositoryImpl implements CaseContactRepository {
  const CaseContactRepositoryImpl(this._source);
  final CaseContactSource _source;

  Future<CaseContactAccess> _request(
    String owner,
    String function,
    Map<String, dynamic> params,
  ) async {
    try {
      final row = await _source.request(owner, function, params);
      final dto = CaseContactDto.fromMap(row);
      return CaseContactAccess(
        canEdit: dto.canEdit,
        version: dto.version,
        suggestedName: dto.suggestedName,
        suggestedPhone: dto.suggestedPhone,
        contact: dto.name == null
            ? null
            : CaseContact(
                name: dto.name!,
                phone: dto.phone!,
                sharePhoto: dto.sharePhoto,
                avatarUri: dto.avatarUri,
              ),
      );
    } on ContactSourceFailure catch (error) {
      throw CaseContactFailure(switch (error.code) {
        '42501' => CaseContactFailureKind.forbidden,
        '23514' => CaseContactFailureKind.invalid,
        '40001' => CaseContactFailureKind.conflict,
        _ => CaseContactFailureKind.unavailable,
      });
    } catch (_) {
      throw const CaseContactFailure(CaseContactFailureKind.unavailable);
    }
  }

  @override
  Future<CaseContactAccess> read(String owner, CaseContactTarget target) =>
      _request(owner, 'read_case_contact', {
        'p_source': target.source,
        'p_id': target.id,
      });
  @override
  Future<CaseContactAccess> save(
    String owner,
    CaseContactTarget target,
    CaseContactDraft draft,
  ) => _request(owner, 'set_case_contact', {
    'p_source': target.source,
    'p_id': target.id,
    'p_enabled': draft.enabled,
    'p_name': draft.name,
    'p_phone': draft.phone,
    'p_share_photo': draft.sharePhoto,
    'p_version': draft.version,
  });
  @override
  Future<void> open(String phone, {required bool message}) async {
    try {
      await _source.open(phone, message: message);
    } catch (_) {
      throw const CaseContactFailure(CaseContactFailureKind.unavailable);
    }
  }
}

class UnavailableCaseContactRepository implements CaseContactRepository {
  const UnavailableCaseContactRepository();
  Never _fail() =>
      throw const CaseContactFailure(CaseContactFailureKind.unavailable);
  @override
  Future<CaseContactAccess> read(
    String owner,
    CaseContactTarget target,
  ) async => _fail();
  @override
  Future<CaseContactAccess> save(
    String owner,
    CaseContactTarget target,
    CaseContactDraft draft,
  ) async => _fail();
  @override
  Future<void> open(String phone, {required bool message}) async => _fail();
}
