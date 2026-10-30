import 'dart:typed_data';
import '../../domain/entities/sighting.dart';
import '../../domain/repositories/sighting_repository.dart';

class UnavailableSightingRepository implements SightingRepository {
  const UnavailableSightingRepository();
  @override
  Future<SightingReceipt> submit(String owner, SightingDraft draft) async =>
      throw const SightingFailure(SightingIssue.unavailable);
  @override
  Future<SightingPoint> locate() async =>
      throw const SightingFailure(SightingIssue.location);
  @override
  Future<Uint8List?> choosePhoto({required bool camera}) async =>
      throw const SightingFailure(SightingIssue.photo);
}
