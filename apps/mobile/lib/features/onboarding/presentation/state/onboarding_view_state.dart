final class OnboardingViewState {
  const OnboardingViewState({
    this.page = 0,
    this.isBusy = false,
    this.hasError = false,
  });
  final int page;
  final bool isBusy;
  final bool hasError;
}
