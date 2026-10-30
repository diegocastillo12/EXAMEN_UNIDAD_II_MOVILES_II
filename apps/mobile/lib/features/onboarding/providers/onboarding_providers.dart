import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../domain/use_cases/check_onboarding.dart';
import '../domain/use_cases/complete_onboarding.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => throw StateError('OnboardingRepository must be injected.'),
);
final checkOnboardingProvider = Provider<CheckOnboarding>(
  (ref) => CheckOnboarding(ref.watch(onboardingRepositoryProvider)),
);
final completeOnboardingProvider = Provider<CompleteOnboarding>(
  (ref) => CompleteOnboarding(ref.watch(onboardingRepositoryProvider)),
);
