import '../repositories/onboarding_repository.dart';

final class CompleteOnboarding {
  const CompleteOnboarding(this._repository);
  final OnboardingRepository _repository;
  Future<void> call() => _repository.complete();
}
