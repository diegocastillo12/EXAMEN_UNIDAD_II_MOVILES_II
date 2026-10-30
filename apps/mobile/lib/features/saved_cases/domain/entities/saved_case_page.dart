import '../../../../core/domain/entities/public_case_card.dart';

class SavedCasePage {
  SavedCasePage({required List<PublicCaseCard> items, this.cursor})
    : items = List.unmodifiable(items);
  final List<PublicCaseCard> items;
  final String? cursor;
}
