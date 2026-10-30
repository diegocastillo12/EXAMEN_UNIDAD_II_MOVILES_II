import assert from 'node:assert/strict';
import { realpathSync, readFileSync } from 'node:fs';
import { resolve, relative, isAbsolute, dirname } from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { sharpPackages } from './package-native-images.mjs';

async function check(entry) {
  const { default: sharp } = await import(pathToFileURL(entry).href);
  const jpeg = await sharp({ create: { width: 16, height: 12, channels: 3, background: '#ccc' } }).jpeg().toBuffer();
  const { data, info } = await sharp(jpeg).resize(224, 224, { fit: 'cover' }).removeAlpha().toColourspace('srgb').raw().toBuffer({ resolveWithObject: true });
  assert.equal(info.width, 224);
  assert.equal(info.height, 224);
  assert.equal(info.channels, 3);
  assert.equal(data.length, 224 * 224 * 3);
  console.log(`Packaged sharp ${sharp.versions.sharp} / libvips ${sharp.versions.vips}: JPEG decode and resize PASS (${process.platform}-${process.arch})`);
}

if (process.argv[2] === '--entry') {
  await check(process.argv[3]);
} else {
  // Resolve from the shipped server, never the build's development dependencies.
  const server = realpathSync(resolve(process.argv[2] || '.output/server'));
  for (const file of sharpPackages(server)) {
    const pkg = JSON.parse(readFileSync(file, 'utf8'));
    // Nitro ships the import condition; CJS wrappers can be absent.
    const entry = resolve(dirname(file), pkg.exports?.['.']?.import?.default || pkg.main);
    const location = relative(server, realpathSync(entry));
    assert.ok(!location.startsWith('..') && !isAbsolute(location), 'sharp must resolve inside the shipped server');
    // Separate processes avoid Windows DLL name collisions across libvips versions.
    const result = spawnSync(process.execPath, [fileURLToPath(import.meta.url), '--entry', entry], { stdio: 'inherit' });
    assert.equal(result.status, 0, `Packaged sharp ${pkg.version} failed: ${result.error || result.signal || result.status}`);
  }
}
