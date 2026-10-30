import 'package:geolocator/geolocator.dart';

enum DeviceLocationIssue { denied, disabled }

class DeviceLocationSource {
  const DeviceLocationSource();

  Future<({double latitude, double longitude})> locate() async {
    if (!await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 5),
    )) {
      throw DeviceLocationIssue.disabled;
    }
    var permission = await Geolocator.checkPermission().timeout(
      const Duration(seconds: 5),
    );
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw DeviceLocationIssue.denied;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }
}
