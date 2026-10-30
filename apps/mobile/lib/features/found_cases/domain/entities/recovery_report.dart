import '../../../lost_cases/domain/entities/lost_case.dart';
import 'found_case.dart';

class RecoveryReport {
  const RecoveryReport.pet(PublishedLostCase value)
    : petCase = value,
      report = null;
  const RecoveryReport.community(FoundPublication value)
    : report = value,
      petCase = null;
  final PublishedLostCase? petCase;
  final FoundPublication? report;
  bool get fromPet => petCase != null;
  String get id => petCase?.id ?? report!.id;
  String get key => '${fromPet ? 'pet' : 'community'}:$id';
  String get status => petCase?.status ?? report!.status;
  Uri? get coverUri => petCase?.coverUri ?? report?.coverUri;
  bool get pending => {'draft', 'discarded'}.contains(status);
}
