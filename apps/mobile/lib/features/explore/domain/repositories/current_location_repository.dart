import '../../../places/domain/entities/search_place.dart';

abstract class CurrentLocationRepository {
  Future<SearchPlace> locate();
}
