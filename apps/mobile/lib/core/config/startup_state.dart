enum StartupStatus { missingConfiguration, invalidConfiguration, failed, ready }

class StartupState {
  const StartupState(this.status);

  final StartupStatus status;

  bool get isReady => status == StartupStatus.ready;
}
