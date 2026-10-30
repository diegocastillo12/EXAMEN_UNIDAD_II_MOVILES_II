abstract interface class OnboardingRepository {
  Future<bool> isCompleted(String userId);
  Future<void> complete();
}
