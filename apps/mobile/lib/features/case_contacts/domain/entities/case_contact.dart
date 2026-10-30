typedef CaseContactTarget = ({String source, String id});

enum CaseContactFailureKind { unavailable, forbidden, invalid, conflict }

class CaseContactFailure implements Exception {
  const CaseContactFailure(this.kind);
  final CaseContactFailureKind kind;
}

class CaseContact {
  const CaseContact({
    required this.name,
    required this.phone,
    this.sharePhoto = false,
    this.avatarUri,
  });
  final String name, phone;
  final bool sharePhoto;
  final Uri? avatarUri;
}

class CaseContactAccess {
  const CaseContactAccess({
    this.contact,
    this.canEdit = false,
    this.version = 0,
    this.suggestedName = '',
    this.suggestedPhone = '',
  });
  final CaseContact? contact;
  final bool canEdit;
  final int version;
  final String suggestedName;
  final String suggestedPhone;
}

class CaseContactDraft {
  const CaseContactDraft({
    required this.enabled,
    required this.name,
    required this.phone,
    required this.sharePhoto,
    required this.version,
  });
  final bool enabled, sharePhoto;
  final String name, phone;
  final int version;
}
