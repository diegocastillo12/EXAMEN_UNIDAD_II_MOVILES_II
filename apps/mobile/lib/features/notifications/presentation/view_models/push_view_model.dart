import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/push.dart';
import '../../providers/notification_providers.dart';
import '../state/push_state.dart';

final pushViewModelProvider = NotifierProvider<PushViewModel, PushState>(
  PushViewModel.new,
);

class PushViewModel extends Notifier<PushState> {
  String? _owner;
  bool _identityResolved = false;
  int _generation = 0;
  @override
  PushState build() {
    ref.listen(notificationSessionProvider, (previous, next) {
      final owner = next.isLoading || next.hasError
          ? null
          : next.asData?.value?.userId;
      if (!next.isLoading &&
          (!_identityResolved || owner != _owner || next.hasError)) {
        _identityResolved = true;
        _owner = owner;
        _generation++;
        Future.microtask(() {
          if (ref.mounted) state = PushState(openId: state.openId);
        });
        unawaited(_sync(owner));
      }
    }, fireImmediately: true);
    final subscription = ref.read(watchPushSignalsProvider)().listen((event) {
      if (!ref.mounted) return;
      if (event == PushSignal.tokenChanged && !state.busy) {
        unawaited(_sync(_owner));
      }
      if (event == PushSignal.opened) {
        state = PushState(openId: state.openId + 1);
      }
    }, onError: (Object _) {});
    ref.onDispose(() {
      _generation++;
      subscription.cancel();
    });
    return const PushState();
  }

  Future<void> _sync(String? owner) async {
    try {
      await ref.read(synchronizePushProvider)(owner);
    } catch (_) {
      /* Retried on next session, token change or explicit activation. */
    }
  }

  Future<void> enable() async {
    final owner = _owner;
    if (owner == null || state.busy) return;
    final generation = _generation;
    state = PushState(
      busy: true,
      openId: state.openId,
      noticeId: state.noticeId,
    );
    try {
      final result = await ref.read(enablePushProvider)(owner);
      if (!ref.mounted || generation != _generation) return;
      state = PushState(
        openId: state.openId,
        noticeId: state.noticeId + 1,
        error: result != PushAvailability.ready,
        notice: switch (result) {
          PushAvailability.ready =>
            'Teléfono registrado. La recepción depende de tus preferencias.',
          PushAvailability.denied =>
            'El permiso está desactivado. Puedes habilitarlo en los ajustes del teléfono.',
          PushAvailability.unconfigured =>
            'Los avisos del teléfono no están disponibles en esta versión. Puedes consultar tu bandeja.',
        },
      );
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = PushState(
          openId: state.openId,
          noticeId: state.noticeId + 1,
          error: true,
          notice: 'No pudimos registrar el teléfono. Puedes reintentar.',
        );
      }
    }
  }
}
