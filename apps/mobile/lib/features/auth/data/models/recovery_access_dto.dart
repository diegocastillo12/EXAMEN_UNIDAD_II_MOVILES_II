import '../../domain/entities/recovery_access.dart';

final class RecoveryAccessDto {
  const RecoveryAccessDto({this.active = false, this.invalid = false});
  final bool active;
  final bool invalid;
  RecoveryAccess toEntity() => invalid
      ? RecoveryAccess.invalid
      : active
      ? RecoveryAccess.ready
      : RecoveryAccess.idle;
}
