import '../repositories/push_repository.dart';

class EnablePush {
  const EnablePush(this.repository);
  final PushRepository repository;
  Future<PushAvailability> call(String owner) => repository.enable(owner);
}

class SynchronizePush {
  const SynchronizePush(this.repository);
  final PushRepository repository;
  Future<void> call(String? owner) => repository.synchronize(owner);
}

class WatchPushSignals {
  const WatchPushSignals(this.repository);
  final PushRepository repository;
  Stream<PushSignal> call() => repository.watch();
}
