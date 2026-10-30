import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/explore_case_preview.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/failures/explore_failure.dart';
import '../../providers/explore_providers.dart';

final exploreCasePreviewViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ExploreCasePreviewViewModel, ExploreCasePreview, ExploreCase>(
      ExploreCasePreviewViewModel.new,
      retry: (_, _) => null,
    );

class ExploreCasePreviewViewModel extends AsyncNotifier<ExploreCasePreview> {
  ExploreCasePreviewViewModel(this.item);
  final ExploreCase item;

  @override
  Future<ExploreCasePreview> build() async {
    final session = await ref.watch(exploreSessionProvider.future);
    if (session == null || !ref.mounted) {
      throw const ExploreFailure(ExploreFailureKind.forbidden);
    }
    return ref.read(readExploreCasePreviewProvider)(item);
  }
}
