import '../models/onboarding_record_dto.dart';

abstract interface class OnboardingDataSource {
  Future<OnboardingRecordDto> read(String userId);
  Future<void> complete();
}
