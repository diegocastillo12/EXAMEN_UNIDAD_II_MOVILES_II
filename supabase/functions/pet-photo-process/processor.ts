import {
  ImageMagick,
  initializeImageMagick,
  MagickFormat,
  ResourceLimits,
} from "@imagemagick/magick-wasm";

export class InvalidPhoto extends Error {}

// Check JPEG dimensions before invoking a decoder. Only normalized JPEG reaches
// the server; the native gallery accepts other supported formats and converts.
export function jpegDimensions(
  bytes: Uint8Array,
): { width: number; height: number } {
  if (
    bytes.length < 4 || bytes.length > 2097152 || bytes[0] !== 255 ||
    bytes[1] !== 216
  ) throw new InvalidPhoto();
  let offset = 2;
  while (offset + 3 < bytes.length) {
    if (bytes[offset++] !== 255) throw new InvalidPhoto();
    while (bytes[offset] === 255) offset++;
    const marker = bytes[offset++];
    if (marker === 217 || marker === 218) break;
    if (marker === 1 || marker === 216 || marker >= 208 && marker <= 215) {
      continue;
    }
    const length = bytes[offset] * 256 + bytes[offset + 1];
    if (length < 2 || offset + length > bytes.length) throw new InvalidPhoto();
    if ([192, 193, 194].includes(marker)) {
      if (length < 8) throw new InvalidPhoto();
      const height = bytes[offset + 3] * 256 + bytes[offset + 4];
      const width = bytes[offset + 5] * 256 + bytes[offset + 6];
      if (!width || !height || width > 1280 || height > 1280) {
        throw new InvalidPhoto();
      }
      return { width, height };
    }
    offset += length;
  }
  throw new InvalidPhoto();
}

export async function initializeProcessor() {
  await initializeImageMagick(
    await Deno.readFile(new URL("./assets/magick.wasm", import.meta.url)),
  );
  ResourceLimits.width = 1280n;
  ResourceLimits.height = 1280n;
  ResourceLimits.memory = 67108864n;
  ResourceLimits.disk = 0n;
}

export function processPhoto(bytes: Uint8Array) {
  const dimensions = jpegDimensions(bytes);
  try {
    return ImageMagick.read(bytes, MagickFormat.Jpeg, (image) => {
      if (
        image.width !== dimensions.width || image.height !== dimensions.height
      ) throw new InvalidPhoto();
      image.autoOrient();
      image.strip();
      image.quality = 85;
      const original = image.write(
        MagickFormat.Jpeg,
        (data) => Uint8Array.from(data),
      );
      const scale = Math.min(1, 320 / Math.max(image.width, image.height));
      image.resize(
        Math.max(1, Math.round(image.width * scale)),
        Math.max(1, Math.round(image.height * scale)),
      );
      image.strip();
      image.quality = 75;
      const thumbnail = image.write(
        MagickFormat.Jpeg,
        (data) => Uint8Array.from(data),
      );
      if (original.length > 2097152 || thumbnail.length > 262144) {
        throw new InvalidPhoto();
      }
      return { original, thumbnail };
    });
  } catch (_) {
    throw new InvalidPhoto();
  }
}
