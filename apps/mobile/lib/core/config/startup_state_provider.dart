import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'startup_state.dart';

final startupStateProvider = Provider<StartupState>(
  (ref) => const StartupState(StartupStatus.missingConfiguration),
);
