import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/failures/profile_failure.dart';

final class ProfileEditState {
  const ProfileEditState({
    required this.profile,
    required this.displayName,
    required this.city,
    this.contactPhone = '',
    this.saving = const AsyncData(null),
    this.issue,
    this.errorId = 0,
    this.saved = false,
    this.citySelected = true,
  });
  factory ProfileEditState.fromProfile(AccountProfile profile) =>
      ProfileEditState(
        profile: profile,
        displayName: profile.displayName ?? '',
        city: profile.city ?? '',
        contactPhone: profile.contactPhone ?? '',
      );
  final AccountProfile profile;
  final String displayName;
  final String city;
  final String contactPhone;
  final AsyncValue<void> saving;
  final ProfileFailureKind? issue;
  final int errorId;
  final bool saved;
  final bool citySelected;
  bool get isBusy => saving.isLoading;
  bool get isDirty =>
      displayName.trim() != (profile.displayName ?? '') ||
      city.trim() != (profile.city ?? '') ||
      contactPhone.trim() != (profile.contactPhone ?? '');
}
