import '../entities/push.dart';
export '../entities/push.dart';

abstract interface class PushRepository {
  Future<PushAvailability> enable(String owner);
  Future<void> synchronize(String? owner);
  Stream<PushSignal> watch();
}
