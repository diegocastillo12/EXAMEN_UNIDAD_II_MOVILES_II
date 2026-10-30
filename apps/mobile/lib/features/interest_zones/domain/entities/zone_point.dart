import '../failures/zone_failure.dart';

class ZonePoint {
  const ZonePoint._(this.latitude, this.longitude);
  factory ZonePoint(double? latitude, double? longitude) {
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 85 ||
        longitude.abs() > 180) {
      throw const ZoneFailure(ZoneFailureKind.invalidPoint);
    }
    return ZonePoint._(latitude, longitude);
  }
  factory ZonePoint.parse(String latitude, String longitude) => ZonePoint(
    double.tryParse(latitude.trim().replaceAll(',', '.')),
    double.tryParse(longitude.trim().replaceAll(',', '.')),
  );
  final double latitude;
  final double longitude;
}
