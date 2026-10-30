import '../../domain/entities/sighting.dart';

class SightingReceiptDto {
  const SightingReceiptDto(this.id, this.receivedAt, this.late);
  factory SightingReceiptDto.fromJson(Map<String, dynamic> row) =>
      SightingReceiptDto(
        row['id'] as String,
        DateTime.parse(row['receivedAt'] as String),
        row['late'] as bool,
      );
  final String id;
  final DateTime receivedAt;
  final bool late;
  SightingReceipt toEntity() => SightingReceipt(id, receivedAt, late);
}
