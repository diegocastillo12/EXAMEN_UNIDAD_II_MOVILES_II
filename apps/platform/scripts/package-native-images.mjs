import assert from 'node:assert/strict';
import { createRequire, findPackageJSON } from 'node:module';
import { cp, mkdir, realpath, rm } from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import { dirname, isAbsolute, relative, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

export function sharpPackages(root) {
  const base = pathToFileURL(resolve(root, 'package.json'));
  const transformers = pathToFileURL(findPackageJSON('@huggingface/transformers', base));
  return new Set([findPackageJSON('sharp', base), findPackageJSON('sharp', transformers)]);
}

export async function packageNativeImages(root, output) {
  const server = await realpath(output);
  const sources = new Map([...sharpPackages(root)].map(file => [JSON.parse(readFileSync(file, 'utf8')).version, file]));
  for (const file of sharpPackages(server)) {
    const pkg = JSON.parse(readFileSync(file, 'utf8'));
    const source = sources.get(pkg.version);
    assert.ok(source, `Missing build dependency sharp ${pkg.version}`);
    const require = createRequire(pathToFileURL(source));
    const target = resolve(dirname(await realpath(file)), 'node_modules/@img');
    await mkdir(target, { recursive: true });
    const location = relative(server, await realpath(target));
    assert.ok(!location.startsWith('..') && !isAbsolute(location), 'Native dependencies must stay inside the server output');
    for (const name of Object.keys(pkg.optionalDependencies || {}).filter(name => name.startsWith('@img/sharp-'))) {
      let native;
      try { native = require.resolve(`${name}/package`); }
      catch (error) {
        if (error.code === 'MODULE_NOT_FOUND') continue; // Other OS/CPU optional packages.
        throw error;
      }
      const destination = resolve(target, name.slice('@img/'.length));
      // Replace traced links with real sibling packages. ELF RPATH is relative
      // to the native addon's real location, not Node's dependency symlinks.
      await rm(destination, { recursive: true, force: true });
      await cp(dirname(native), destination, { recursive: true, dereference: true });
    }
  }
}
