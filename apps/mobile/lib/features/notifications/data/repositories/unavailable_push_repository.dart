import '../../domain/repositories/push_repository.dart';

class UnavailablePushRepository implements PushRepository {
  const UnavailablePushRepository();
  @override
  Future<PushAvailability> enable(String owner) async =>
      PushAvailability.unconfigured;
  @override
  Future<void> synchronize(String? owner) async {}
  @override
  Stream<PushSignal> watch() => const Stream.empty();
}
