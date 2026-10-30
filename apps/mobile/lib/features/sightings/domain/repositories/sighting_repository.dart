import 'dart:typed_data';
import '../entities/sighting.dart';

abstract interface class SightingRepository {
  Future<SightingReceipt> submit(String owner, SightingDraft draft);
  Future<SightingPoint> locate();
  Future<Uint8List?> choosePhoto({required bool camera});
}
