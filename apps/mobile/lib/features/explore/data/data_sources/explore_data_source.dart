import '../../domain/entities/explore_query.dart';
import '../models/explore_page_dto.dart';

abstract interface class ExploreDataSource {
  Future<ExplorePageDto> search(
    String owner,
    ExploreQuery query,
    String? cursor,
  );
  Future<Uri> cover(String owner, String source, String path);
}

class ExploreSourceFailure implements Exception {
  const ExploreSourceFailure(this.forbidden);
  final bool forbidden;
}
