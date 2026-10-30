import 'dart:typed_data';
import 'dart:isolate';
import 'photo_preparation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PhotoGalleryFailureKind { invalidPhoto, unavailable, cameraUnavailable }

class PhotoGalleryFailure implements Exception {
  const PhotoGalleryFailure(this.kind);
  final PhotoGalleryFailureKind kind;
}

Uint8List preparePhoto(Uint8List bytes) {
  try {
    return normalizePhoto(bytes);
  } on PhotoPreparationFailure {
    throw const PhotoGalleryFailure(PhotoGalleryFailureKind.invalidPhoto);
  }
}

abstract interface class PhotoGallerySource {
  Future<Uint8List?> choose(
    String owner,
    String pet,
    bool existing, {
    bool camera = false,
  });
  Future<Uint8List?> recover(String owner, String pet, bool existing);
}

class NativePhotoGallerySource implements PhotoGallerySource {
  const NativePhotoGallerySource(
    this._picker, {
    this.pendingMarker = 'pet_photo_pending',
  });
  final ImagePicker _picker;
  final String pendingMarker;
  Future<Uint8List?> _prepare(XFile? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (const bool.fromEnvironment('dart.library.js_interop')) {
      return preparePhoto(bytes);
    }
    return Isolate.run(() => preparePhoto(bytes));
  }

  @override
  Future<Uint8List?> choose(
    String owner,
    String pet,
    bool existing, {
    bool camera = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final context = '$owner|$pet|$existing';
    if (!await preferences.setString(pendingMarker, context)) {
      throw const PhotoGalleryFailure(PhotoGalleryFailureKind.unavailable);
    }
    try {
      return await _prepare(
        await _picker.pickImage(
          source: camera ? ImageSource.camera : ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 90,
          requestFullMetadata: false,
        ),
      );
    } on PhotoGalleryFailure {
      rethrow;
    } catch (_) {
      throw PhotoGalleryFailure(
        camera
            ? PhotoGalleryFailureKind.cameraUnavailable
            : PhotoGalleryFailureKind.unavailable,
      );
    } finally {
      if (preferences.getString(pendingMarker) == context) {
        await preferences.remove(pendingMarker);
      }
    }
  }

  @override
  Future<Uint8List?> recover(String owner, String pet, bool existing) async {
    final preferences = await SharedPreferences.getInstance();
    final context = preferences.getString(pendingMarker);
    if (context == null) return null;
    final parts = context.split('|');
    if (parts.length != 3) return null;
    if (parts[0] == owner &&
        (parts[2] == 'true' ? parts[1] != pet : existing)) {
      return null;
    }
    try {
      final lost = await _picker.retrieveLostData();
      if (parts[0] != owner) return null;
      if (lost.exception != null) {
        throw const PhotoGalleryFailure(PhotoGalleryFailureKind.unavailable);
      }
      return await _prepare(lost.files?.firstOrNull);
    } on UnimplementedError {
      return null;
    } finally {
      if (preferences.getString(pendingMarker) == context) {
        await preferences.remove(pendingMarker);
      }
    }
  }
}
