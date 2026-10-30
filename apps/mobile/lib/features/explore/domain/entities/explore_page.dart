import '../../../../core/domain/entities/public_case_card.dart';

typedef ExploreCase = PublicCaseCard;

class ExplorePage {
  ExplorePage({required List<ExploreCase> items, this.nextCursor})
    : items = List.unmodifiable(items);
  final List<ExploreCase> items;
  final String? nextCursor;
}
