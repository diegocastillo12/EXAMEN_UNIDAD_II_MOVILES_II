import 'dart:math' show min;

({double latitude, double longitude}) approximateCaseLocation(
  double latitude,
  double longitude,
) => (
  latitude: (latitude * 100).floor() / 100 + .005,
  longitude: min(179.995, (longitude * 100).floor() / 100 + .005),
);
