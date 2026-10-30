import 'dart:typed_data';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pet_photo_data_source.dart';
import '../models/pet_photo_dto.dart';

class SupabasePetPhotoSource implements PetPhotoDataSource {
  const SupabasePetPhotoSource(this._client);
  final SupabaseClient _client;
  void _owner(String id) {
    if (_client.auth.currentUser?.id != id) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.forbidden);
    }
  }

  PetPhotoSourceFailure _failure(String? code, Object? message) =>
      PetPhotoSourceFailure(
        code == '42501' || code == '403' || code == '401'
            ? PetPhotoSourceFailureKind.forbidden
            : code == '40001' || code == '409'
            ? PetPhotoSourceFailureKind.conflict
            : message == 'photo_limit'
            ? PetPhotoSourceFailureKind.limit
            : code == '422' || code == '413'
            ? PetPhotoSourceFailureKind.invalidPhoto
            : PetPhotoSourceFailureKind.unavailable,
      );
  void _diagnostic(String operation, String kind, String? code) {
    // Never log SDK messages, photo bytes, paths or signed URL credentials.
    final safeCode = RegExp(r'^[A-Z0-9]{3,10}$').hasMatch(code ?? '')
        ? code
        : 'unknown';
    final message = '$operation failed: $kind code=$safeCode';
    developer.log(message, name: 'pet_photos');
    assert(() {
      Zone.current.print('[pet_photos] $message');
      return true;
    }());
  }

  Future<T> _run<T>(
    String owner,
    String operation,
    Future<T> Function() action,
  ) async {
    _owner(owner);
    try {
      final result = await action();
      _owner(owner);
      return result;
    } on PetPhotoSourceFailure {
      rethrow;
    } on PostgrestException catch (e) {
      _diagnostic(operation, 'PostgREST', e.code);
      throw _failure(e.code, e.message);
    } on StorageException catch (e) {
      _diagnostic(operation, 'Storage', e.statusCode);
      throw _failure(e.statusCode, null);
    } on FunctionException catch (e) {
      _diagnostic(operation, 'Edge', '${e.status}');
      final detail = e.details;
      throw _failure('${e.status}', detail is Map ? detail['error'] : null);
    } catch (e) {
      _diagnostic(operation, '${e.runtimeType}', null);
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.unavailable);
    }
  }

  Future<PetPhotoDto> _signed(
    Map<String, dynamic> row,
    String owner,
    String pet,
  ) async {
    _owner(owner);
    if (row['owner_id'] != owner || row['pet_id'] != pet) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.forbidden);
    }
    Uri? uri;
    Uri? thumbnail;
    if (row['status'] == 'published') {
      final processed = row['processed_at'] != null;
      final path = '$owner/$pet/${row['id']}.jpg';
      uri = Uri.parse(
        await _client.storage
            .from(processed ? 'pet-photo-renditions' : 'pet-photos')
            .createSignedUrl(path, 3600),
      );
      if (processed) {
        thumbnail = Uri.parse(
          await _client.storage
              .from('pet-photo-thumbnails')
              .createSignedUrl(path, 3600),
        );
      }
    }
    return PetPhotoDto.fromMap(row, uri: uri, thumbnailUri: thumbnail);
  }

  @override
  Future<List<PetPhotoDto>> list(String owner, String pet) =>
      _run(owner, 'list', () async {
        final rows = await _client.rpc(
          'list_pet_photos',
          params: {'p_pet_id': pet},
        );
        return Future.wait(
          (rows as List).map(
            (row) => _signed(Map<String, dynamic>.from(row as Map), owner, pet),
          ),
        );
      });
  @override
  Future<PetPhotoDto> upload(
    String owner,
    String pet,
    String id,
    Uint8List bytes,
  ) => _run(owner, 'upload', () async {
    final response = await _client.functions.invoke(
      'pet-photo-process',
      body: bytes,
      headers: {
        'Content-Type': 'image/jpeg',
        'x-pet-id': pet,
        'x-photo-id': id,
      },
    );
    if (response.data is! Map) {
      throw const PetPhotoSourceFailure(PetPhotoSourceFailureKind.unavailable);
    }
    return _signed(Map<String, dynamic>.from(response.data as Map), owner, pet);
  });
  @override
  Future<void> remove(String owner, String pet, String id) =>
      _run(owner, 'remove', () async {
        await _client.rpc(
          'begin_pet_photo_removal',
          params: {'p_id': id, 'p_pet_id': pet},
        );
        for (final bucket in [
          'pet-photos',
          'pet-photo-renditions',
          'pet-photo-thumbnails',
        ]) {
          _owner(owner);
          try {
            await _client.storage.from(bucket).remove(['$owner/$pet/$id.jpg']);
          } on StorageException catch (e) {
            if (e.statusCode != '404') rethrow;
          }
        }
        _owner(owner);
        await _client.rpc('remove_pet_photo', params: {'p_id': id});
      });
  @override
  Future<List<PetPhotoDto>> setPrimary(
    String owner,
    String pet,
    String id,
    int expectedVersion,
  ) => _run(owner, 'set_primary', () async {
    await _client.rpc(
      'set_primary_pet_photo',
      params: {
        'p_pet_id': pet,
        'p_photo_id': id,
        'p_expected_version': expectedVersion,
      },
    );
    return list(owner, pet);
  });
}
