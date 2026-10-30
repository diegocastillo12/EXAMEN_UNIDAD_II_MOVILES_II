import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';

class ExploreState {
  ExploreState({
    required this.owner,
    required this.query,
    required List<ExploreCase> items,
    this.cursor,
    this.refreshing = false,
    this.applying = false,
    this.appending = false,
    this.failed = false,
    this.notice,
    this.noticeId = 0,
    this.locationLabel = '',
    this.centerName = '',
  }) : items = List.unmodifiable(items);
  final String owner;
  final ExploreQuery query;
  final List<ExploreCase> items;
  final String? cursor, notice;
  final bool refreshing, appending, failed, applying;
  final int noticeId;
  final String locationLabel, centerName;

  bool get busy => refreshing || appending;
  bool get needsLocation => query.latitude == null || query.longitude == null;
}
