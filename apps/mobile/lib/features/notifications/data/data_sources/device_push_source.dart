enum DevicePushSignal { opened, tokenChanged, received }

abstract interface class DevicePushSource {
  bool get configured;
  Future<bool> requestPermission();
  Future<String?> token();
  Future<void> deleteToken();
  Stream<DevicePushSignal> watch();
}
