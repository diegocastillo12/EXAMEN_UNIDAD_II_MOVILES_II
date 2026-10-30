import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/profile_failure.dart';
import '../../providers/profile_providers.dart';
import '../state/profile_edit_state.dart';
import '../../domain/entities/account_profile.dart';

final profileViewModelProvider =
    AsyncNotifierProvider.autoDispose<ProfileViewModel, ProfileEditState>(
      ProfileViewModel.new,
      retry: (_, _) => null,
    );

class ProfileViewModel extends AsyncNotifier<ProfileEditState> {
  int _generation = 0;
  int _errorId = 0;
  @override
  Future<ProfileEditState> build() async {
    _generation++;
    final read = ref.watch(readProfileProvider);
    final session = await ref.watch(profileSessionProvider.future);
    if (session == null) {
      throw const ProfileFailure(ProfileFailureKind.signedOut);
    }
    return ProfileEditState.fromProfile(await read(session.userId));
  }

  void retry() => ref.invalidateSelf();
  void applyAvatar(AccountProfile remote) {
    final current = state.asData?.value;
    if (current == null || current.profile.userId != remote.userId) return;
    state = AsyncData(
      ProfileEditState(
        profile: AccountProfile(
          userId: current.profile.userId,
          displayName: current.profile.displayName,
          city: current.profile.city,
          contactPhone: current.profile.contactPhone,
          email: remote.email,
          avatarUri: remote.avatarUri,
        ),
        displayName: current.displayName,
        city: current.city,
        contactPhone: current.contactPhone,
        saving: current.saving,
        citySelected: current.citySelected,
        issue: current.issue,
        errorId: current.errorId,
      ),
    );
  }

  void edit({String? displayName, String? city, String? contactPhone}) {
    final current = state.asData?.value;
    if (current == null || current.isBusy) return;
    final keepIssue =
        (current.issue == ProfileFailureKind.invalidName &&
            displayName == null) ||
        (current.issue == ProfileFailureKind.invalidCity && city == null) ||
        (current.issue == ProfileFailureKind.invalidPhone &&
            contactPhone == null);
    state = AsyncData(
      ProfileEditState(
        profile: current.profile,
        displayName: displayName ?? current.displayName,
        city: city ?? current.city,
        contactPhone: contactPhone ?? current.contactPhone,
        citySelected: city == null
            ? current.citySelected
            : city.trim().isEmpty || city == current.profile.city,
        errorId: current.errorId,
        issue: keepIssue ? current.issue : null,
      ),
    );
  }

  void discard() {
    final current = state.asData?.value;
    if (current != null && !current.isBusy) {
      state = AsyncData(ProfileEditState.fromProfile(current.profile));
    }
  }

  void selectCity(String city) {
    final current = state.asData?.value;
    if (current == null || current.isBusy) return;
    state = AsyncData(
      ProfileEditState(
        profile: current.profile,
        displayName: current.displayName,
        city: city,
        contactPhone: current.contactPhone,
        citySelected: true,
        issue:
            current.issue == ProfileFailureKind.invalidName ||
                current.issue == ProfileFailureKind.invalidPhone
            ? current.issue
            : null,
        errorId: current.errorId,
      ),
    );
  }

  Future<void> save() async {
    final current = state.asData?.value;
    if (current == null || current.isBusy || !current.isDirty) return;
    final generation = _generation;
    final update = ref.read(updateProfileProvider);
    state = AsyncData(
      ProfileEditState(
        profile: current.profile,
        displayName: current.displayName,
        city: current.city,
        contactPhone: current.contactPhone,
        saving: const AsyncLoading(),
        citySelected: current.citySelected,
      ),
    );
    try {
      final saved = await update(
        current.profile.userId,
        displayName: current.displayName,
        city: current.city,
        contactPhone: current.contactPhone,
        citySelected: current.citySelected,
      );
      if (ref.mounted && generation == _generation) {
        state = AsyncData(
          ProfileEditState(
            profile: saved,
            displayName: saved.displayName ?? '',
            city: saved.city ?? '',
            contactPhone: saved.contactPhone ?? '',
            saved: true,
          ),
        );
      }
    } catch (error, stack) {
      if (ref.mounted && generation == _generation) {
        final failure = error is ProfileFailure
            ? error
            : const ProfileFailure(ProfileFailureKind.unavailable);
        state = AsyncData(
          ProfileEditState(
            profile: current.profile,
            displayName: current.displayName,
            city: current.city,
            contactPhone: current.contactPhone,
            saving: AsyncError(failure, stack),
            citySelected: current.citySelected,
            issue: failure.kind,
            errorId: ++_errorId,
          ),
        );
      }
    }
  }
}
