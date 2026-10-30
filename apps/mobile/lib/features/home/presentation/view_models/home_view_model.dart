import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/home_view_state.dart';

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, HomeViewState>(
      HomeViewModel.new,
    );

class HomeViewModel extends Notifier<HomeViewState> {
  bool _refreshing = false;
  int _generation = 0;
  @override
  HomeViewState build() => const HomeViewState();
  void select(HomeSection section) {
    if (state.section != section) {
      _generation++;
      state = HomeViewState(section: section);
    }
  }

  Future<void> refresh(Future<void> Function() reload) async {
    if (_refreshing || state.section != HomeSection.home) return;
    _refreshing = true;
    final generation = _generation;
    state = HomeViewState(noticeId: state.noticeId);
    try {
      await reload();
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = HomeViewState(refreshError: true, noticeId: state.noticeId + 1);
      }
    } finally {
      _refreshing = false;
    }
  }
}
