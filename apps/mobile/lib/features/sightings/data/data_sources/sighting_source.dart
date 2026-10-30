import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/sighting.dart';

abstract interface class SightingSource {
  Future<Map<String, dynamic>> submit(String owner, SightingDraft draft);
  Future<({double latitude, double longitude, double accuracy})> locate();
  Future<Uint8List?> choosePhoto(bool camera);
}

class NativeSightingSource implements SightingSource {
  NativeSightingSource(this.supabase, this.client, this.picker, this.baseUrl);
  final SupabaseClient supabase;
  final http.Client client;
  final ImagePicker picker;
  final String baseUrl;
  @override
  Future<Map<String, dynamic>> submit(String owner, SightingDraft draft) async {
    final base = Uri.parse(baseUrl);
    if (base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment) {
      throw const SightingFailure(SightingIssue.unavailable);
    }
    // Refresh through the SDK; tokens never enter domain or presentation.
    var session = supabase.auth.currentSession;
    if (session == null ||
        session.user.id != owner ||
        supabase.auth.currentUser?.id != owner) {
      throw const SightingFailure(SightingIssue.forbidden);
    }
    if (session.isExpired) {
      session = (await supabase.auth.refreshSession()).session;
    }
    if (session == null ||
        session.user.id != owner ||
        supabase.auth.currentUser?.id != owner) {
      throw const SightingFailure(SightingIssue.forbidden);
    }
    final request =
        http.MultipartRequest(
            'POST',
            base.resolve(
              '/api/app/cases/${draft.target.community ? 'found' : 'lost'}/${draft.target.id}/sightings',
            ),
          )
          ..followRedirects = false
          ..headers['Authorization'] = 'Bearer ${session.accessToken}'
          ..fields['report'] = jsonEncode({
            'id': draft.id,
            'observedAt': DateTime.fromMillisecondsSinceEpoch(
              draft.observedAt.millisecondsSinceEpoch,
              isUtc: true,
            ).toIso8601String(),
            'point': {
              'latitude': draft.point.latitude,
              'longitude': draft.point.longitude,
              'source': draft.point.source,
              'accuracy': draft.point.accuracy,
            },
            'comment': draft.comment,
          });
    if (draft.photo != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          draft.photo!,
          filename: 'evidence.jpg',
        ),
      );
    }
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 30));
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(
      const Duration(seconds: 20),
    )) {
      if (bytes.length + chunk.length > 8192) {
        throw const SightingFailure(SightingIssue.unavailable);
      }
      bytes.addAll(chunk);
    }
    if (supabase.auth.currentUser?.id != owner) {
      throw const SightingFailure(SightingIssue.forbidden);
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const SightingFailure(SightingIssue.forbidden);
    }
    final value = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final issue = switch (value['error']) {
        'invalid' => SightingIssue.invalid,
        'closed' => SightingIssue.closed,
        'blocked' => SightingIssue.blocked,
        'conflict' => SightingIssue.conflict,
        'rate_limited' => SightingIssue.rateLimited,
        'photo' => SightingIssue.photo,
        _ => SightingIssue.unavailable,
      };
      throw SightingFailure(
        issue,
        (value['fields'] is List
                ? (value['fields'] as List).whereType<String>()
                : <String>[])
            .toSet(),
      );
    }
    return value;
  }

  @override
  Future<({double latitude, double longitude, double accuracy})>
  locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const SightingFailure(SightingIssue.location);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw const SightingFailure(SightingIssue.location);
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );
    return (latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy);
  }

  @override
  Future<Uint8List?> choosePhoto(bool camera) async {
    final file = await picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    if (await file.length() > 8388608) {
      throw const SightingFailure(SightingIssue.photo);
    }
    return file.readAsBytes();
  }
}
