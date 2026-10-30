import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lost_case.dart';
import '../models/lost_case_dto.dart';
import 'lost_case_data_source.dart';

class SupabaseLostCaseDataSource implements LostCaseDataSource {
  const SupabaseLostCaseDataSource(this._client, {Duration? publicationTimeout})
    : _publicationTimeout = publicationTimeout;
  final SupabaseClient _client;
  final Duration? _publicationTimeout;
  void _diagnostic(String message) {
    developer.log(message, name: 'lost_cases');
    assert(() {
      // Also visible in Android/Flutter debug logs after a debugger detaches.
      Zone.current.print('[lost_cases] $message');
      return true;
    }());
  }

  void _identity(String owner) {
    if (_client.auth.currentUser?.id != owner) {
      throw const CaseSourceFailure(CaseFailureKind.forbidden);
    }
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CaseSourceFailure {
      rethrow;
    } on TimeoutException {
      _diagnostic('Publication response deadline exceeded');
      throw const CaseSourceFailure(CaseFailureKind.timedOut);
    } on PostgrestException catch (e) {
      // Codes help diagnose RPC/proxy failures without logging SDK messages,
      // report fields, URLs, credentials or response bodies.
      final code = RegExp(r'^[A-Z0-9]{3,10}$').hasMatch(e.code ?? '')
          ? e.code
          : 'unknown';
      _diagnostic('Request rejected: code=$code');
      throw CaseSourceFailure(switch (e.message) {
        'case_already_active' => CaseFailureKind.activeCase,
        'case_photos_unverified' => CaseFailureKind.photosUnverified,
        'case_pet_incomplete' => CaseFailureKind.incompletePet,
        _ => switch (e.code) {
          '42501' ||
          '401' ||
          '403' ||
          'PGRST301' ||
          'PGRST302' ||
          'PGRST303' => CaseFailureKind.forbidden,
          '40001' || 'PT409' => CaseFailureKind.conflict,
          '55P03' => CaseFailureKind.busy,
          '23514' => CaseFailureKind.invalid,
          '23505' => CaseFailureKind.conflict,
          _ => CaseFailureKind.unavailable,
        },
      });
    } catch (e) {
      _diagnostic('Request failed: ${e.runtimeType}');
      throw const CaseSourceFailure(CaseFailureKind.unavailable);
    }
  }

  @override
  Future<LostCaseDto> publish(String owner, LostCaseDraft draft) =>
      _run(() async {
        _identity(owner);
        final rows = await _client
            .rpc(
              'publish_lost_case',
              params: {
                'p_id': draft.id,
                'p_pet_id': draft.petId,
                'p_pet_version': draft.petVersion,
                'p_occurred_at': draft.occurredAt.toUtc().toIso8601String(),
                'p_latitude': draft.latitude,
                'p_longitude': draft.longitude,
                'p_place_reference': draft.placeReference.trim(),
                'p_photo_ids': draft.photoIds,
              },
            )
            .timeout(_publicationTimeout ?? const Duration(seconds: 30));
        _identity(owner);
        return LostCaseDto(
          Map<String, dynamic>.from((rows as List).single as Map),
        );
      });
  @override
  Future<LostCaseDto?> readPublic(String id) => _run(() async {
    final rows =
        await _client.rpc('read_recovery_pet_case', params: {'p_id': id})
            as List;
    return rows.isEmpty
        ? null
        : LostCaseDto(Map<String, dynamic>.from(rows.single as Map));
  });
  @override
  Future<List<LostCaseDto>> listMine(String owner) => _run(() async {
    _identity(owner);
    final rows = await _client.rpc('list_my_lost_case_cards') as List;
    _identity(owner);
    return rows
        .map((r) => LostCaseDto(Map<String, dynamic>.from(r as Map)))
        .toList();
  });
  @override
  Future<Uri?> photoUri(String path) async {
    try {
      return Uri.parse(
        await _client.storage
            .from('pet-photo-renditions')
            .createSignedUrl(path, 300),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String owner, String id) => _run(() async {
    _identity(owner);
    await _client
        .rpc('delete_lost_case', params: {'p_id': id})
        .timeout(const Duration(seconds: 15));
    _identity(owner);
  });
}
