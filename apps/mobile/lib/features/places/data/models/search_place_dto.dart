import '../../domain/entities/search_place.dart';

class SearchPlaceDto {
  const SearchPlaceDto(this.label, this.latitude, this.longitude);
  final String label;
  final double latitude, longitude;
  factory SearchPlaceDto.fromJson(
    Map<String, dynamic> row, {
    bool citiesOnly = false,
  }) {
    final coordinates = (row['geometry'] as Map)['coordinates'] as List;
    final lat = (coordinates[1] as num).toDouble(),
        lon = (coordinates[0] as num).toDouble();
    if (!lat.isFinite || !lon.isFinite || lat.abs() > 85 || lon.abs() > 180) {
      throw const FormatException('Invalid public place');
    }
    final properties = Map<String, dynamic>.from(row['properties'] as Map);
    if (citiesOnly &&
        properties['type'] != 'city' &&
        !(properties['osm_key'] == 'place' &&
            const {
              'city',
              'town',
              'village',
              'municipality',
              'hamlet',
            }.contains(properties['osm_value']))) {
      throw const FormatException('Not a city result');
    }
    final label =
        (citiesOnly
                ? ['name', 'state', 'country']
                : [
                    'name',
                    'street',
                    'housenumber',
                    'district',
                    'city',
                    'state',
                    'country',
                  ])
            .map((key) => properties[key]?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet()
            .join(', ');
    if (label.isEmpty) throw const FormatException('Unnamed place');
    if (citiesOnly &&
        (label.runes.length > 120 ||
            (properties['name']?.toString().trim().isEmpty ?? true))) {
      throw const FormatException('City label too long');
    }
    return SearchPlaceDto(label, lat, lon);
  }
  SearchPlace toEntity() =>
      SearchPlace(label: label, latitude: latitude, longitude: longitude);
}
