import '../../domain/entities/found_case.dart';

class RecoveryCaseState {
  RecoveryCaseState({
    required List<PublicFoundCase> notices,
    this.busy = false,
    this.error = false,
    this.confirmed = false,
  }) : notices = List.unmodifiable(notices);
  final List<PublicFoundCase> notices;
  final bool busy, error, confirmed;
}
