import {
  ImageMagick,
  MagickColors,
  MagickFormat,
} from "@imagemagick/magick-wasm";
import {
  initializeProcessor,
  InvalidPhoto,
  jpegDimensions,
  processPhoto,
} from "./processor.ts";

await initializeProcessor();
function assert(value: unknown, message = "assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
function fixture(width: number, height: number) {
  return ImageMagick.read(
    MagickColors.Red,
    width,
    height,
    (image) => image.write(MagickFormat.Jpeg, (data) => Uint8Array.from(data)),
  );
}
function withExif(bytes: Uint8Array) {
  // Real little-endian TIFF with GPS IFD, plus an identifiable description.
  const tiff = new Uint8Array(90);
  const view = new DataView(tiff.buffer);
  tiff.set([73, 73, 42, 0, 8, 0, 0, 0]);
  view.setUint16(8, 2, true);
  view.setUint16(10, 0x010e, true);
  view.setUint16(12, 2, true);
  view.setUint32(14, 17, true);
  view.setUint32(18, 62, true);
  view.setUint16(22, 0x8825, true);
  view.setUint16(24, 4, true);
  view.setUint32(26, 1, true);
  view.setUint32(30, 38, true);
  view.setUint16(38, 1, true);
  view.setUint16(40, 1, true);
  view.setUint16(42, 2, true);
  view.setUint32(44, 2, true);
  tiff[48] = 78;
  tiff.set(new TextEncoder().encode("private-location\0"), 62);
  const exif = new Uint8Array(6 + tiff.length);
  exif.set([69, 120, 105, 102, 0, 0]);
  exif.set(tiff, 6);
  const output = new Uint8Array(bytes.length + exif.length + 4);
  output.set(bytes.slice(0, 2));
  output.set([255, 225, (exif.length + 2) >> 8, (exif.length + 2) & 255], 2);
  output.set(exif, 6);
  output.set(bytes.slice(2), 6 + exif.length);
  return output;
}

Deno.test("Server decodes, strips EXIF/GPS bytes and produces bounded JPEG renditions", () => {
  const bytes = withExif(fixture(1280, 640));
  const started = performance.now();
  const { original, thumbnail } = processPhoto(bytes);
  for (const output of [original, thumbnail]) {
    const text = new TextDecoder("latin1").decode(output);
    assert(!text.includes("Exif") && !text.includes("private-location"));
    ImageMagick.read(
      output,
      (image) => assert(image.format === MagickFormat.Jpeg),
    );
  }
  const main = jpegDimensions(original), small = jpegDimensions(thumbnail);
  assert(main.width === 1280 && main.height === 640);
  assert(small.width === 320 && small.height === 160);
  assert(original.length <= 2097152 && thumbnail.length <= 262144);
  console.log(
    `1280×640: ${
      (performance.now() - started).toFixed(0)
    }ms locales (no acredita CPU hosted).`,
  );
});

Deno.test("Forged JPEG, truncated content, oversize bytes and dimensions are rejected", () => {
  const valid = fixture(20, 10);
  const forged = valid.slice();
  // Preserve a valid header but remove scan contents: full decoder must reject.
  const start = forged.findIndex((value, index) =>
    value === 255 && forged[index + 1] === 218
  );
  const invalid = [
    new Uint8Array([1, 2, 3]),
    new Uint8Array(2097153),
    valid.slice(0, 25),
    forged.slice(0, start + 3),
  ];
  for (const bytes of invalid) {
    let failed = false;
    try {
      processPhoto(bytes);
    } catch (error) {
      failed = error instanceof InvalidPhoto;
    }
    assert(failed);
  }
  const huge = valid.slice();
  for (let i = 0; i < huge.length - 9; i++) {
    if (huge[i] === 255 && [192, 193, 194].includes(huge[i + 1])) {
      huge[i + 7] = 32;
      huge[i + 8] = 0;
      break;
    }
  }
  let failed = false;
  try {
    processPhoto(huge);
  } catch (error) {
    failed = error instanceof InvalidPhoto;
  }
  assert(failed);
});

Deno.test("Maximum square input stays bounded and repeated output is deterministic", () => {
  const bytes = fixture(1280, 1280);
  const started = performance.now();
  const first = processPhoto(bytes), second = processPhoto(bytes);
  assert(
    first.original.length === second.original.length &&
      first.original.every((v, i) => v === second.original[i]),
  );
  assert(jpegDimensions(first.thumbnail).width === 320);
  console.log(
    `2×1280²: ${(performance.now() - started).toFixed(0)}ms locales; RSS ${
      Math.round(Deno.memoryUsage().rss / 1048576)
    }MiB.`,
  );
});
