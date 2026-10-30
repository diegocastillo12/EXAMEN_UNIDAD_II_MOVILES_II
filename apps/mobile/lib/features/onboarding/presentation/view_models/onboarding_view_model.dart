import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_providers.dart';
import '../state/onboarding_view_state.dart';
import 'entry_view_model.dart';

final onboardingViewModelProvider =
    NotifierProvider.autoDispose<OnboardingViewModel, OnboardingViewState>(
      OnboardingViewModel.new,
    );

class OnboardingViewModel extends Notifier<OnboardingViewState> {
  @override
  OnboardingViewState build() => const OnboardingViewState();
  void selectPage(int page) {
    if (!state.isBusy && page >= 0 && page < 3) {
      state = OnboardingViewState(page: page);
    }
  }

  Future<void> next() async {
    if (state.isBusy) return;
    if (state.page < 2) {
      selectPage(state.page + 1);
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    if (state.isBusy) return;
    final page = state.page;
    state = OnboardingViewState(page: page, isBusy: true);
    try {
      await ref.read(completeOnboardingProvider)();
      if (ref.mounted) {
        state = OnboardingViewState(page: page);
        ref.invalidate(entryViewModelProvider);
      }
    } catch (_) {
      if (ref.mounted) state = OnboardingViewState(page: page, hasError: true);
    }
  }
}
