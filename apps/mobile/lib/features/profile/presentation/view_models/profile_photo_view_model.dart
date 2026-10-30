import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../providers/profile_providers.dart';
import 'profile_view_model.dart';

class ProfilePhotoState {
  const ProfilePhotoState({
    this.result = const AsyncData(null),
    this.bytes,
    this.recovered = false,
  });
  final AsyncValue<AccountProfile?> result;
  final Uint8List? bytes;
  final bool recovered;
}

final profilePhotoViewModelProvider =
    NotifierProvider.autoDispose<ProfilePhotoViewModel, ProfilePhotoState>(
      ProfilePhotoViewModel.new,
    );

class ProfilePhotoViewModel extends Notifier<ProfilePhotoState> {
  int _generation = 0;
  @override
  ProfilePhotoState build() {
    _generation++;
    ref.watch(profileSessionProvider);
    return const ProfilePhotoState();
  }

  String? get _identity {
    final value = ref.read(profileViewModelProvider);
    return value.isLoading || value.hasError
        ? null
        : value.asData?.value.profile.userId;
  }

  Future<void> recover() async {
    if (state.result.isLoading || state.bytes != null) return;
    final id = _identity;
    if (id == null) return;
    final generation = _generation;
    try {
      final bytes = await ref.read(changeProfilePhotoProvider).recover(id);
      if (ref.mounted && generation == _generation && bytes != null) {
        // Recovery is preview only: the account owner confirms before upload.
        state = ProfilePhotoState(bytes: bytes, recovered: true);
      }
    } catch (_) {
      /* No recovered selection must not block ordinary editing. */
    }
  }

  Future<void> choose() async {
    if (state.result.isLoading) return;
    final id = _identity;
    if (id == null) return;
    final generation = ++_generation;
    final lifetime = ref.keepAlive();
    ref.read(profileViewModelProvider.notifier).edit();
    state = const ProfilePhotoState(result: AsyncLoading());
    try {
      final bytes = await ref.read(changeProfilePhotoProvider).choose(id);
      if (!ref.mounted || generation != _generation) return;
      if (_identity != id || bytes == null) {
        state = const ProfilePhotoState();
        return;
      }
      state = ProfilePhotoState(result: const AsyncLoading(), bytes: bytes);
      await _upload(id, bytes, generation);
    } catch (error, stack) {
      _fail(error, stack, generation);
    } finally {
      lifetime.close();
    }
  }

  Future<void> retry() async {
    if (state.result.isLoading || state.bytes == null || _identity == null) {
      return;
    }
    final bytes = state.bytes!;
    final id = _identity!;
    final generation = ++_generation;
    final lifetime = ref.keepAlive();
    state = ProfilePhotoState(
      result: const AsyncLoading(),
      bytes: bytes,
      recovered: state.recovered,
    );
    try {
      await _upload(id, bytes, generation);
    } finally {
      lifetime.close();
    }
  }

  void discard() {
    if (!state.result.isLoading) {
      _generation++;
      state = const ProfilePhotoState();
    }
  }

  Future<void> _upload(String id, Uint8List bytes, int generation) async {
    try {
      final profile = await ref
          .read(changeProfilePhotoProvider)
          .upload(id, bytes);
      if (!ref.mounted || generation != _generation) return;
      if (_identity != id || profile.userId != id) {
        state = const ProfilePhotoState();
        return;
      }
      ref.read(profileViewModelProvider.notifier).applyAvatar(profile);
      state = ProfilePhotoState(result: AsyncData(profile));
    } catch (error, stack) {
      _fail(error, stack, generation);
    }
  }

  void _fail(Object error, StackTrace stack, int generation) {
    if (!ref.mounted || generation != _generation) return;
    final failure = error is ProfileFailure
        ? error
        : const ProfileFailure(ProfileFailureKind.unavailable);
    state = ProfilePhotoState(
      result: AsyncError(failure, stack),
      bytes: state.bytes,
      recovered: state.recovered,
    );
  }
}
