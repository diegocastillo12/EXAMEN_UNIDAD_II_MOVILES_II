final class OnboardingRecordDto {
  const OnboardingRecordDto({required this.completed});
  factory OnboardingRecordDto.fromMap(Map<String, dynamic> map) =>
      OnboardingRecordDto(completed: map['onboarding_completed_at'] != null);
  final bool completed;
}
