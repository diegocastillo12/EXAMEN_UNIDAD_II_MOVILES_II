import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/gallery_profile_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/profile/data/data_sources/profile_photo_source.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_application_entrehuellas/features/profile/domain/use_cases/change_profile_photo.dart';
import 'package:flutter_application_entrehuellas/features/profile/providers/profile_providers.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_application_entrehuellas/features/profile/presentation/view_models/profile_photo_view_model.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_profile.dart';
import 'support/fake_profile_photo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Recovered native selection is only returned to its original account',
    () async {
      final picker = _LostPicker(
        img.encodeJpg(img.Image(width: 10, height: 10)),
      );
      final source = GalleryProfilePhotoSource(picker);
      SharedPreferences.setMockInitialValues({
        GalleryProfilePhotoSource.pendingOwnerKey: 'one',
      });
      expect(await source.recover('two'), isNull);
      SharedPreferences.setMockInitialValues({
        GalleryProfilePhotoSource.pendingOwnerKey: 'one',
      });
      expect(await source.recover('one'), isNotNull);
      expect(
        (await SharedPreferences.getInstance()).getString(
          GalleryProfilePhotoSource.pendingOwnerKey,
        ),
        isNull,
      );
    },
  );
  test('JPEG output is square, bounded and drops source EXIF/GPS', () {
    final original = img.Image(width: 120, height: 80);
    original.exif.imageIfd.imageDescription = 'private-location-metadata';
    original.exif.gpsIfd[1] = img.IfdValueAscii('N');
    final input = img.encodeJpg(original);
    expect(
      utf8.decode(input, allowMalformed: true),
      contains('private-location-metadata'),
    );
    final bytes = prepareProfilePhoto(input);
    final decoded = img.decodeJpg(bytes)!;
    expect(decoded.width, 512);
    expect(decoded.height, 512);
    expect(bytes.length, lessThanOrEqualTo(2097152));
    expect(
      utf8.decode(bytes, allowMalformed: true),
      isNot(contains('private-location-metadata')),
    );
    expect(decoded.exif.gpsIfd[1], isNull);
    expect(
      () => prepareProfilePhoto(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<ProfilePhotoSourceFailure>()),
    );
  });

  late FakeProfile profiles;
  late FakeProfilePhoto photos;
  late FakeAuthRepository auth;
  late ProviderContainer container;
  late ProviderSubscription<ProfilePhotoState> photoSubscription;
  setUp(() {
    profiles = FakeProfile();
    photos = FakeProfilePhoto(profiles);
    auth = FakeAuthRepository()..current = const AuthSession(userId: 'one');
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profiles),
        profilePhotoRepositoryProvider.overrideWithValue(photos),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    final a = container.listen(profileViewModelProvider, (_, _) {});
    photoSubscription = container.listen(
      profilePhotoViewModelProvider,
      (_, _) {},
    );
    addTearDown(a.close);
    addTearDown(photoSubscription.close);
  });
  tearDown(() async {
    container.dispose();
    await auth.controller.close();
  });

  test(
    'Upload rejects invalid JPEG and over-limit payload before touching storage',
    () {
      final useCase = ChangeProfilePhoto(photos);
      expect(
        () => useCase.upload('one', Uint8List.fromList([1, 2, 3])),
        throwsA(isA<ProfileFailure>()),
      );
      expect(
        () => useCase.upload('one', Uint8List(2097153)),
        throwsA(isA<ProfileFailure>()),
      );
      expect(photos.uploads, 0);
    },
  );
  test(
    'Cancellation never uploads; upload confirmation preserves editable draft and retries safely',
    () async {
      await container.read(profileViewModelProvider.future);
      final photo = container.read(profilePhotoViewModelProvider.notifier);
      await photo.choose();
      expect(photos.uploads, 0);
      container
          .read(profileViewModelProvider.notifier)
          .edit(city: 'Draft city');
      photos.selection = img.encodeJpg(img.Image(width: 10, height: 10));
      photos.fail = true;
      photos.pending = Completer<void>();
      final upload = photo.choose();
      await Future<void>.delayed(Duration.zero);
      await photo.choose();
      expect(photos.uploads, 1);
      expect(
        container.read(profilePhotoViewModelProvider).result.isLoading,
        true,
      );
      photos.pending!.complete();
      await upload;
      expect(
        container.read(profileViewModelProvider).requireValue.profile.avatarUri,
        isNull,
      );
      expect(container.read(profilePhotoViewModelProvider).bytes, isNotNull);
      photos.fail = false;
      await photo.retry();
      expect(photos.uploads, 2);
      expect(
        container.read(profileViewModelProvider).requireValue.city,
        'Draft city',
      );
      expect(
        container.read(profileViewModelProvider).requireValue.profile.avatarUri,
        isNotNull,
      );
    },
  );

  test(
    'Confirmed upload still updates the current header after closing the photo editor',
    () async {
      await container.read(profileViewModelProvider.future);
      photos.selection = img.encodeJpg(img.Image(width: 10, height: 10));
      photos.pending = Completer<void>();
      final upload = container
          .read(profilePhotoViewModelProvider.notifier)
          .choose();
      await Future<void>.delayed(Duration.zero);
      photoSubscription.close();
      await Future<void>.delayed(Duration.zero);
      photos.pending!.complete();
      await upload;
      expect(
        container.read(profileViewModelProvider).requireValue.profile.avatarUri,
        isNotNull,
      );
    },
  );
  test(
    'Recovered selection needs explicit confirmation and cannot automatically upload',
    () async {
      await container.read(profileViewModelProvider.future);
      photos.recovered = img.encodeJpg(img.Image(width: 10, height: 10));
      final model = container.read(profilePhotoViewModelProvider.notifier);
      await model.recover();
      expect(photos.uploads, 0);
      expect(container.read(profilePhotoViewModelProvider).recovered, true);
      await model.retry();
      expect(photos.uploads, 1);
    },
  );

  test(
    'Account switch clears pending bytes and ignores the old upload result',
    () async {
      await container.read(profileViewModelProvider.future);
      photos.selection = img.encodeJpg(img.Image(width: 10, height: 10));
      photos.pending = Completer<void>();
      final model = container.read(profilePhotoViewModelProvider.notifier);
      final upload = model.choose();
      await Future<void>.delayed(Duration.zero);
      auth.emit(const AuthSession(userId: 'two'));
      await Future<void>.delayed(Duration.zero);
      await container.read(profileViewModelProvider.future);
      photos.pending!.complete();
      await upload;
      expect(
        container.read(profileViewModelProvider).requireValue.profile.userId,
        'two',
      );
      expect(
        container.read(profileViewModelProvider).requireValue.profile.avatarUri,
        isNull,
      );
      expect(container.read(profilePhotoViewModelProvider).bytes, isNull);
    },
  );
}

class _LostPicker extends ImagePicker {
  _LostPicker(this.bytes);
  final Uint8List bytes;
  @override
  Future<LostDataResponse> retrieveLostData() async =>
      LostDataResponse(files: [XFile.fromData(bytes, name: 'avatar.jpg')]);
}
