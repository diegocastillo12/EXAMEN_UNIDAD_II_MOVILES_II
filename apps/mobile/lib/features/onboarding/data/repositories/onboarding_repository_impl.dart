import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/failures/onboarding_failure.dart';
import '../data_sources/onboarding_data_source.dart';

final class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._source);
  final OnboardingDataSource _source;
  @override
  Future<bool> isCompleted(String userId) async {
    try {
      return (await _source.read(userId)).completed;
    } catch (_) {
      throw const OnboardingFailure();
    }
  }

  @override
  Future<void> complete() async {
    try {
      await _source.complete();
    } catch (_) {
      throw const OnboardingFailure();
    }
  }
}
