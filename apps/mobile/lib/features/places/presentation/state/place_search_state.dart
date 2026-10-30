import '../../domain/entities/search_place.dart';

class PlaceSearchState {
  const PlaceSearchState({
    this.places = const [],
    this.busy = false,
    this.notice,
    this.noticeId = 0,
  });
  final List<SearchPlace> places;
  final bool busy;
  final String? notice;
  final int noticeId;
}
