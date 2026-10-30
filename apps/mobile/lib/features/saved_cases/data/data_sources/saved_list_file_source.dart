import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'saved_list_cipher.dart';

/// Stage 2: only an authenticated encrypted envelope may reach disk.
class SavedListFileSource {
  SavedListFileSource({
    required this.cipher,
    this.directory = getApplicationSupportDirectory,
  });
  final SavedListCipher cipher;
  final Future<Directory> Function() directory;
  Future<void> _pending = Future.value();

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<File> _file(String owner) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(owner)) {
      throw const FormatException('Invalid account identifier');
    }
    final root = await directory();
    return File(
      path.join(
        root.path,
        'offline_saved_cases',
        Uri.encodeComponent(owner),
        'cases.json',
      ),
    );
  }

  Future<void> write(String owner, String contents) =>
      _exclusive(() => _write(owner, contents));

  Future<void> _write(String owner, String contents) async {
    final file = await _file(owner);
    final plaintext = Uint8List.fromList(utf8.encode(contents));
    if (plaintext.length > 4 * 1024 * 1024) {
      throw const FormatException('Offline list is too large');
    }
    final sealed = await cipher.encrypt(owner, plaintext);
    final envelope = jsonEncode({
      'version': 2,
      'algorithm': 'AES-256-GCM',
      'sealed': base64Encode(sealed),
    });
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(envelope, flush: true);
    await temporary.rename(file.path);
  }

  Future<String?> read(String owner) => _exclusive(() => _read(owner));

  Future<String?> _read(String owner) async {
    final file = await _file(owner);
    if (!await file.exists()) return null;
    if (await file.length() > 6 * 1024 * 1024) {
      throw const FormatException('Offline list is too large');
    }
    final envelope =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    // Do not accept or migrate a plaintext file silently.
    if (envelope['version'] != 2 || envelope['algorithm'] != 'AES-256-GCM') {
      throw const FormatException('Encrypted offline list required');
    }
    final sealed = base64Decode(envelope['sealed'] as String);
    return utf8.decode(await cipher.decrypt(owner, sealed));
  }

  Future<void> clearAll() => _exclusive(() async {
    // Key deletion first makes even a leftover ciphertext unrecoverable.
    await cipher.deleteKeys();
    final root = await directory();
    final folder = Directory(path.join(root.path, 'offline_saved_cases'));
    if (await folder.exists()) await folder.delete(recursive: true);
  });
}
