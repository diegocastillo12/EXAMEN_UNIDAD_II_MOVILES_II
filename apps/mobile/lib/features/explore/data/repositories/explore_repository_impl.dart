import '../../domain/entities/explore_query.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/failures/explore_failure.dart';
import '../../domain/repositories/explore_repository.dart';
import '../data_sources/explore_data_source.dart';
import '../models/explore_page_dto.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  const ExploreRepositoryImpl(this._source);
  final ExploreDataSource _source;
  @override
  Future<ExplorePage> search(
    String owner,
    ExploreQuery query, {
    String? cursor,
  }) async {
    try {
      final dto = await _source.search(owner, query, cursor);
      final items = await Future.wait(
        dto.items.map((r) async {
          final path = r['cover_path'] as String?;
          final cover = path == null
              ? null
              : await _source.cover(owner, r['source'] as String, path);
          return ExplorePageDto.toEntity(r, cover);
        }),
      );
      return ExplorePage(items: items, nextCursor: dto.nextCursor);
    } on ExploreSourceFailure catch (e) {
      throw ExploreFailure(
        e.forbidden
            ? ExploreFailureKind.forbidden
            : ExploreFailureKind.unavailable,
      );
    } catch (_) {
      throw const ExploreFailure(ExploreFailureKind.unavailable);
    }
  }
}
