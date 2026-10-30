import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/failures/onboarding_failure.dart';

final class UnavailableOnboardingRepository implements OnboardingRepository {
  const UnavailableOnboardingRepository();
  @override
  Future<bool> isCompleted(String userId) async =>
      throw const OnboardingFailure();
  @override
  Future<void> complete() async => throw const OnboardingFailure();
}
