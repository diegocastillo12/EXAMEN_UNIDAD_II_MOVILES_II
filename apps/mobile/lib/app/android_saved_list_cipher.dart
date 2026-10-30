import 'package:flutter/services.dart';
import '../features/saved_cases/data/data_sources/saved_list_cipher.dart';

/// Thin native transport injected at composition; contains no product rules.
class AndroidSavedListCipher implements SavedListCipher {
  const AndroidSavedListCipher();
  static const _channel = MethodChannel('entrehuellas/offline-list-cipher');

  Future<Uint8List> _invoke(String method, String owner, Uint8List data) async {
    final result = await _channel.invokeMethod<Uint8List>(method, {
      'owner': owner,
      'data': data,
    });
    if (result == null) throw StateError('Native cipher unavailable');
    return result;
  }

  @override
  Future<Uint8List> encrypt(String owner, Uint8List plaintext) =>
      _invoke('encrypt', owner, plaintext);

  @override
  Future<Uint8List> decrypt(String owner, Uint8List sealed) =>
      _invoke('decrypt', owner, sealed);

  @override
  Future<void> deleteKeys() => _channel.invokeMethod<void>('deleteKeys');
}
