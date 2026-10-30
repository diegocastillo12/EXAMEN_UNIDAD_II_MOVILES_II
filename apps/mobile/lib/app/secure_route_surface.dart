import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/presentation/widgets/confirmation_toast.dart';

typedef ScreenProtection = Future<void> Function(String token, bool enabled);

class SecureRouteSurface extends StatefulWidget {
  const SecureRouteSurface({required this.child, this.protection, super.key});
  final Widget child;
  final ScreenProtection? protection;
  @override
  State<SecureRouteSurface> createState() => _SecureRouteSurfaceState();
}

class _SecureRouteSurfaceState extends State<SecureRouteSurface> {
  static int _sequence = 0;
  static const _channel = MethodChannel('entrehuellas/screen-protection');
  late final String _token = 'saved-list-${++_sequence}';
  late Future<void> _acquire;
  bool _ready = false, _failed = false;
  int _notice = 0;

  Future<void> _native(String token, bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('setProtected', {
      'token': token,
      'enabled': enabled,
    });
  }

  ScreenProtection get _transport => widget.protection ?? _native;

  @override
  void initState() {
    super.initState();
    _protect();
  }

  void _protect() {
    _failed = false;
    _acquire = _transport(_token, true);
    unawaited(
      _acquire.then(
        (_) {
          if (mounted) setState(() => _ready = true);
        },
        onError: (Object error, StackTrace stack) {
          if (mounted) {
            setState(() {
              _failed = true;
              _notice++;
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    final transport = _transport;
    unawaited(
      _acquire
          .then((_) => transport(_token, false))
          .catchError((Object error) {}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    return ConfirmationToastHost(
      confirmed: _failed,
      isError: true,
      noticeId: _notice,
      message: 'No pudimos proteger esta pantalla. Reintenta.',
      child: ColoredBox(
        color: const Color(0xFFF9FAFB),
        child: Center(
          child: _failed
              ? TextButton(
                  onPressed: () => setState(_protect),
                  child: const Text('Reintentar'),
                )
              : Semantics(
                  label: 'Protegiendo pantalla',
                  child: const SizedBox.expand(),
                ),
        ),
      ),
    );
  }
}
