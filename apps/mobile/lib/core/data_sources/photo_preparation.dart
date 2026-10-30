import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PhotoPreparationFailure implements Exception {
  const PhotoPreparationFailure();
}

/// Validates decoded dimensions before allocating and copies only pixels.
Uint8List normalizePhoto(
  Uint8List bytes, {
  int maxSide = 1280,
  bool square = false,
}) {
  try {
    if (bytes.isEmpty || bytes.length > 10485760) {
      throw const PhotoPreparationFailure();
    }
    final decoder = img.findDecoderForData(bytes);
    final info = decoder?.startDecode(bytes);
    if (info == null ||
        info.width > 4096 ||
        info.height > 4096 ||
        info.width * info.height > 16000000) {
      throw const PhotoPreparationFailure();
    }
    final raw = decoder!.decodeFrame(0);
    if (raw == null) {
      throw const PhotoPreparationFailure();
    }
    var image = img.bakeOrientation(raw);
    if (square) {
      image = img.copyResizeCropSquare(image, size: maxSide);
    } else if (image.width > maxSide || image.height > maxSide) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? maxSide : null,
        height: image.height > image.width ? maxSide : null,
      );
    }
    final clean = img.Image(width: image.width, height: image.height);
    img.fill(clean, color: img.ColorRgb8(245, 245, 247));
    img.compositeImage(clean, image);
    return img.encodeJpg(clean, quality: 85);
  } on PhotoPreparationFailure {
    rethrow;
  } catch (_) {
    throw const PhotoPreparationFailure();
  }
}
