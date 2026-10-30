import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_entrehuellas/core/theme/app_theme.dart';
import 'package:flutter_application_entrehuellas/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_application_entrehuellas/features/auth/providers/auth_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/data/data_sources/pet_gallery_source.dart';
import 'package:flutter_application_entrehuellas/features/pets/domain/entities/pet_photo.dart';
import 'package:flutter_application_entrehuellas/features/pets/providers/pet_providers.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/view_models/pet_photos_view_model.dart';
import 'package:flutter_application_entrehuellas/features/pets/presentation/widgets/pet_photo_gallery.dart';
import 'app_test.dart' show FakeAuthRepository;
import 'support/fake_pet_photos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Primary selection is a draft; failed save preserves it and re-open reads confirmation',
    () async {
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final repo = FakePetPhotos();
      for (final id in ['first', 'second']) {
        repo.photos[id] = PetPhoto(
          id: id,
          petId: 'pet',
          ownerId: 'one',
          ready: true,
          uri: Uri.parse('https://example.invalid/$id.jpg'),
          isPrimary: id == 'first',
          selectionVersion: 4,
        );
      }
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petPhotoRepositoryProvider.overrideWithValue(repo),
        ],
      );
      final provider = petPhotosViewModelProvider('pet');
      final sub = container.listen(provider, (_, __) {});
      addTearDown(() async {
        sub.close();
        container.dispose();
        await auth.controller.close();
      });
      final model = container.read(provider.notifier);
      await container.read(petSessionProvider.future);
      await model.initialize(true);
      model.stagePrimary('second');
      expect(container.read(provider).visiblePrimaryId, 'second');
      expect(repo.primaryWrites, 0);
      model.discardPending();
      expect(container.read(provider).visiblePrimaryId, 'first');
      expect(container.read(provider).hasPendingChanges, false);
      model.stagePrimary('second');
      repo.failPrimary = true;
      expect(await model.savePendingChanges(), false);
      expect(container.read(provider).pendingPrimaryId, 'second');
      expect(container.read(provider).pendingPrimaryVersion, 4);
      repo.failPrimary = false;
      expect(await model.savePendingChanges(), true);
      expect(container.read(provider).hasPendingChanges, false);
      await model.initialize(true);
      expect(
        container.read(provider).photos.singleWhere((p) => p.isPrimary).id,
        'second',
      );
      model.stagePrimary('first');
      model.stageRemoval('first');
      expect(container.read(provider).pendingPrimaryId, isNull);
      expect(container.read(provider).visiblePrimaryId, 'second');
    },
  );

  test(
    'Native camera denial leaves gallery usable and clears recovery marker',
    () async {
      SharedPreferences.setMockInitialValues({});
      final picker = _CameraPicker();
      final source = NativePetGallerySource(picker);
      await expectLater(
        source.choose('one', 'pet', true, camera: true),
        throwsA(
          isA<PetGalleryFailure>().having(
            (e) => e.kind,
            'kind',
            PetGalleryFailureKind.cameraUnavailable,
          ),
        ),
      );
      expect(
        (await SharedPreferences.getInstance()).getString(
          NativePetGallerySource.marker,
        ),
        isNull,
      );
      expect(await source.choose('one', 'pet', true), isNotNull);
      expect(picker.origins, [ImageSource.camera, ImageSource.gallery]);
    },
  );

  for (final small in [false, true]) {
    testWidgets('Camera and staged principal remain accessible; small=$small', (
      tester,
    ) async {
      if (const bool.fromEnvironment('CAPTURE_PHOTOS')) {
        await _loadFonts(tester);
      }
      tester.view.physicalSize = small
          ? const Size(320, 350)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = FakeAuthRepository()
        ..current = const AuthSession(userId: 'one');
      final repo = FakePetPhotos()
        ..selection = img.encodeJpg(
          img.fill(
            img.Image(width: 100, height: 100),
            color: img.ColorRgb8(180, 170, 160),
          ),
        );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          petPhotoRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await auth.controller.close();
      });
      final key = GlobalKey();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(small ? 2 : 1),
              ),
              child: RepaintBoundary(
                key: key,
                child: Scaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: const PetPhotoGallery(
                        petId: 'pet',
                        existing: false,
                        editable: true,
                        tileSize: 160,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tomar foto'));
      await tester.tap(find.text('Tomar foto'));
      await tester.pumpAndSettle();
      expect(repo.lastOrigin, PetPhotoOrigin.camera);
      expect(repo.attempts, isEmpty);
      final model = container.read(petPhotosViewModelProvider('pet').notifier);
      await model.choose(false);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byIcon(Icons.star_outline_rounded));
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pumpAndSettle();
      final state = container.read(petPhotosViewModelProvider('pet'));
      expect(state.pendingPrimaryId, state.pending.last.id);
      expect(repo.primaryWrites, 0);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      if (const bool.fromEnvironment('CAPTURE_PHOTOS')) {
        await tester.ensureVisible(
          find.byKey(ValueKey('pet_photo_${state.pending.last.id}')),
        );
        await tester.runAsync(
          () => precacheImage(
            ResizeImage(MemoryImage(repo.selection!), width: 160),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final raster =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await raster.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/ui-preview/photos')
            ..createSync(recursive: true);
          File(
            '${folder.path}/primary_${small ? 'small' : 'normal'}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          raster.dispose();
        });
      }
      expect(tester.takeException(), isNull);
      model.discardPending();
      await tester.pumpAndSettle();
      expect(
        container.read(petPhotosViewModelProvider('pet')).hasPendingChanges,
        false,
      );
    });
  }
}

class _CameraPicker extends ImagePicker {
  final origins = <ImageSource>[];
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    origins.add(source);
    if (source == ImageSource.camera) {
      throw PlatformException(code: 'camera_access_denied');
    }
    return XFile.fromData(
      img.encodeJpg(img.Image(width: 16, height: 16)),
      name: 'pet.jpg',
    );
  }
}

Future<void> _loadFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    final configFile = File('.dart_tool/package_config.json').absolute;
    final config =
        jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
    final flutter = (config['packages'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((p) => p['name'] == 'flutter');
    final root = configFile.uri
        .resolve('${flutter['rootUri']}/')
        .resolve('../../bin/cache/artifacts/material_fonts/');
    for (final entry in {
      'sans-serif': [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ],
      'MaterialIcons': ['materialicons-regular.otf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final file in entry.value) {
        loader.addFont(
          File.fromUri(
            root.resolve(file),
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
  });
}
