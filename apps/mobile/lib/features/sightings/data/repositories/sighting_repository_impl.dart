import 'dart:typed_data';
import '../../domain/entities/sighting.dart';
import '../../domain/repositories/sighting_repository.dart';
import '../data_sources/sighting_source.dart';
import '../models/sighting_receipt_dto.dart';

class SightingRepositoryImpl implements SightingRepository {
  const SightingRepositoryImpl(this.source);
  final SightingSource source;
  @override
  Future<SightingReceipt> submit(String owner, SightingDraft draft) async {
    try {
      final row = await source.submit(owner, draft);
      return SightingReceiptDto.fromJson(row).toEntity();
    } on SightingFailure {
      rethrow;
    } catch (_) {
      throw const SightingFailure(SightingIssue.unavailable);
    }
  }

  @override
  Future<SightingPoint> locate() async {
    try {
      final p = await source.locate().timeout(const Duration(seconds: 30));
      return SightingPoint(p.latitude, p.longitude, accuracy: p.accuracy);
    } catch (_) {
      throw const SightingFailure(SightingIssue.location);
    }
  }

  @override
  Future<Uint8List?> choosePhoto({required bool camera}) async {
    try {
      final bytes = await source.choosePhoto(camera);
      return bytes == null
          ? null
          : Uint8List.fromList(bytes).asUnmodifiableView();
    } catch (_) {
      throw const SightingFailure(SightingIssue.photo);
    }
  }
}
