import '../repositories/onboarding_repository.dart';

final class CheckOnboarding {
  const CheckOnboarding(this._repository);
  final OnboardingRepository _repository;
  Future<bool> call(String userId) => _repository.isCompleted(userId);
}
