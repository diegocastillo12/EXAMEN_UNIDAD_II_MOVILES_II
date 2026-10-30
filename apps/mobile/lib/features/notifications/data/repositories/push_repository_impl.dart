import '../../domain/entities/notification.dart';
import '../../domain/repositories/push_repository.dart';
import '../data_sources/device_push_source.dart';
import '../data_sources/notification_source.dart';

class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl(this.device, this.source);
  final DevicePushSource device;
  final NotificationSource source;
  int _generation = 0;
  Future<void> _tail = Future.value();
  Future<T> _ordered<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace stack) {});
    return result;
  }

  String? _lastOwner, _lastToken;
  Future<bool> _register(String owner, int generation) async {
    final token = await device.token();
    if (generation != _generation) return false;
    if (token == null) {
      if (_lastOwner == owner && _lastToken != null) {
        await source.write(owner, 'register_push_device', {
          'p_token': _lastToken,
          'p_enabled': false,
        });
      }
      return false;
    }
    await source.write(owner, 'register_push_device', {
      'p_token': token,
      'p_enabled': true,
    });
    if (generation == _generation) {
      _lastOwner = owner;
      _lastToken = token;
    }
    return generation == _generation;
  }

  @override
  Future<PushAvailability> enable(String owner) {
    final generation = ++_generation;
    return _ordered(() => _enable(owner, generation));
  }

  Future<PushAvailability> _enable(String owner, int generation) async {
    if (!device.configured) return PushAvailability.unconfigured;
    try {
      if (!await device.requestPermission()) return PushAvailability.denied;
      if (!await _register(owner, generation)) {
        throw const NotificationFailure(NotificationIssue.unavailable);
      }
      return PushAvailability.ready;
    } catch (_) {
      throw const NotificationFailure(NotificationIssue.unavailable);
    }
  }

  @override
  Future<void> synchronize(String? owner) {
    final generation = ++_generation;
    return _ordered(() => _synchronize(owner, generation));
  }

  Future<void> _synchronize(String? owner, int generation) async {
    if (!device.configured) return;
    try {
      if (owner == null) {
        _lastOwner = null;
        _lastToken = null;
        await device.deleteToken();
        return;
      }
      await _register(owner, generation);
    } catch (_) {
      throw const NotificationFailure(NotificationIssue.unavailable);
    }
  }

  @override
  Stream<PushSignal> watch() => device.watch().map(
    (event) => switch (event) {
      DevicePushSignal.opened => PushSignal.opened,
      DevicePushSignal.tokenChanged => PushSignal.tokenChanged,
      DevicePushSignal.received => PushSignal.received,
    },
  );
}
