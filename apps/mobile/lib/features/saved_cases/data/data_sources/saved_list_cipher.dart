import 'dart:typed_data';

/// Platform boundary: encryption keys never cross this interface.
abstract interface class SavedListCipher {
  Future<Uint8List> encrypt(String owner, Uint8List plaintext);
  Future<Uint8List> decrypt(String owner, Uint8List sealed);
  Future<void> deleteKeys();
}
