import 'dart:typed_data';
import 'dart:isolate';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/data_sources/photo_preparation.dart';
import 'profile_photo_source.dart';

/// A fresh image copies only pixels, dropping EXIF/GPS from the original.
Uint8List prepareProfilePhoto(Uint8List bytes) {
  try {
    return normalizePhoto(bytes, maxSide: 512, square: true);
  } on PhotoPreparationFailure {
    throw const ProfilePhotoSourceFailure(
      ProfilePhotoSourceFailureKind.invalidPhoto,
    );
  }
}

Future<Uint8List> _prepareWithoutBlocking(Uint8List bytes) async {
  if (const bool.fromEnvironment('dart.library.js_interop')) {
    return prepareProfilePhoto(bytes);
  }
  return Isolate.run(() => prepareProfilePhoto(bytes));
}

final class GalleryProfilePhotoSource implements ProfilePhotoSource {
  GalleryProfilePhotoSource(this._picker);
  final ImagePicker _picker;
  Future<Uint8List?> _prepare(XFile? file) async =>
      file == null ? null : _prepareWithoutBlocking(await file.readAsBytes());
  static const pendingOwnerKey = 'profile_photo_pending_owner';
  @override
  Future<Uint8List?> choose(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(pendingOwnerKey, userId)) {
      throw const ProfilePhotoSourceFailure(
        ProfilePhotoSourceFailureKind.unavailable,
      );
    }
    try {
      return await _prepare(
        await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 90,
          requestFullMetadata: false,
        ),
      );
    } finally {
      if (preferences.getString(pendingOwnerKey) == userId) {
        await preferences.remove(pendingOwnerKey);
      }
    }
  }

  @override
  Future<Uint8List?> recover(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final owner = preferences.getString(pendingOwnerKey);
    if (owner == null) {
      // Another feature may own the native lost selection.
      return null;
    }
    try {
      final lost = await _picker.retrieveLostData();
      if (owner != userId) {
        return null;
      }
      if (lost.exception != null) {
        throw const ProfilePhotoSourceFailure(
          ProfilePhotoSourceFailureKind.unavailable,
        );
      }
      return await _prepare(lost.files?.firstOrNull);
    } on UnimplementedError {
      return null;
    } finally {
      if (preferences.getString(pendingOwnerKey) == owner) {
        await preferences.remove(pendingOwnerKey);
      }
    }
  }
}
