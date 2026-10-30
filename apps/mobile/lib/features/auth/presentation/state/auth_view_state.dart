import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/startup_state.dart';
import '../../domain/entities/auth_session.dart';

final class AuthViewState {
  const AuthViewState({required this.startup, required this.session});

  final StartupState startup;
  final AsyncValue<AuthSession?> session;

  String get startupMessage => switch (startup.status) {
    StartupStatus.missingConfiguration =>
      'Falta configurar el servicio de acceso. Puedes explorar la app.',
    StartupStatus.invalidConfiguration =>
      'La configuración del servicio de acceso no es válida.',
    StartupStatus.failed =>
      'No se pudo preparar el servicio de acceso. Reinicia la app para reintentar.',
    StartupStatus.ready => 'Servicio de acceso preparado.',
  };
}
