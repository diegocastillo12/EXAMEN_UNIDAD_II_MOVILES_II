/// Presentation-only map service configuration; contains no credentials or location.
class MapConfig {
  const MapConfig._();
  static const tileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static bool get usesCarto =>
      Uri.tryParse(tileUrl)?.host == 'basemaps.cartocdn.com';
}
