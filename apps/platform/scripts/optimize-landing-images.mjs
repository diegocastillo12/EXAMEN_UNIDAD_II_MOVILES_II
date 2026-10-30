// Run after changing the original PNG artwork. Originals remain the fallback.
import { readdir, stat } from 'node:fs/promises';
import sharp from 'sharp';
import { fileURLToPath } from 'node:url';

const directory = new URL('../public/images/landing/', import.meta.url);
let originalBytes = 0; let optimizedBytes = 0;
for (const name of (await readdir(directory)).filter(name => name.endsWith('.png')).sort()) {
  const source = fileURLToPath(new URL(name, directory));
  const target = source.replace(/\.png$/, '.webp');
  await sharp(source).webp({ lossless: true, effort: 6 }).toFile(target);
  const original = await sharp(source).ensureAlpha().raw().toBuffer();
  const optimized = await sharp(target).ensureAlpha().raw().toBuffer();
  // WebP discards invisible RGB values under fully transparent pixels.
  for (let i = 0; i < original.length; i += 4) {
    if (original[i + 3] !== optimized[i + 3] || (original[i + 3] > 0 &&
      (original[i] !== optimized[i] || original[i + 1] !== optimized[i + 1] || original[i + 2] !== optimized[i + 2]))) {
      throw new Error(`Visible pixel verification failed: ${name}`);
    }
  }
  originalBytes += (await stat(source)).size; optimizedBytes += (await stat(target)).size;
  if (name.startsWith('hero-')) {
    for (const width of [320, 640]) {
      await sharp(source).resize({ width }).webp({ lossless: true, effort: 6 }).toFile(source.replace(/\.png$/, `-${width}.webp`));
    }
  }
}
console.log(`Landing artwork: ${originalBytes} → ${optimizedBytes} bytes (${(100 * (1 - optimizedBytes / originalBytes)).toFixed(1)}% reduction). Visible pixels and alpha identical.`);
// Public social preview: raster derivative of the approved illustration, no new artwork.
const social = fileURLToPath(new URL('social-reunion.jpg', directory));
await sharp(fileURLToPath(new URL('reunion.png', directory)))
  .flatten({ background: '#ffffff' }).resize(1200, 630, { fit: 'contain', background: '#ffffff' })
  .jpeg({ quality: 90, mozjpeg: true }).toFile(social);
console.log(`Social preview: ${(await stat(social)).size} bytes (1200×630 JPEG).`);
