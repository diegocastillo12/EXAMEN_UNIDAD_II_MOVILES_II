import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/use_cases/read_profile.dart';
import '../domain/use_cases/update_profile.dart';
import '../domain/repositories/profile_photo_repository.dart';
import '../domain/use_cases/change_profile_photo.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => throw StateError('ProfileRepository must be injected.'),
);
final readProfileProvider = Provider(
  (ref) => ReadProfile(ref.watch(profileRepositoryProvider)),
);
final updateProfileProvider = Provider(
  (ref) => UpdateProfile(ref.watch(profileRepositoryProvider)),
);
final profileSessionProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(watchAuthSessionProvider)(),
);
final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>(
  (ref) => throw StateError('ProfilePhotoRepository must be injected.'),
);
final changeProfilePhotoProvider = Provider(
  (ref) => ChangeProfilePhoto(ref.watch(profilePhotoRepositoryProvider)),
);
