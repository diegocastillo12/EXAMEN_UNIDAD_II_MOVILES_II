import assert from 'node:assert/strict';
import { test } from 'node:test';
import { publicCase, ReaderFailure } from '../shared/features/case_reader/domain/case.ts';
import { ReadCase, ReadCasePhoto } from '../shared/features/case_reader/domain/read_case.ts';
import { SupabaseCaseRepository } from '../server/features/case_reader/data/supabase_case_repository.ts';
import { SupabaseCaseDataSource } from '../server/features/case_reader/data/supabase_case_data_source.ts';
import { HttpCaseRepository } from '../shared/features/case_reader/data/http_case_repository.ts';
import { ReaderViewModel } from '../shared/features/case_reader/presentation/reader_view_model.ts';
import { slug, rawActive, active, photo } from './fixtures.mjs';

test('Read use cases reject invalid identifiers before accessing a repository', async () => {
  const reader = new ReadCase({ read() { throw new Error('must not read'); } });
  for (const value of ['', 'A'.repeat(64), '../secret', 'a'.repeat(65), null]) assert.deepEqual(await reader.execute(value), { state: 'unavailable' });
  await assert.rejects(new ReadCasePhoto({}).execute(slug, 3), { kind: 'not_found' });
  await assert.rejects(new ReadCasePhoto({}).execute(slug, -1), { kind: 'not_found' });
});

test('Repository allowlist strips identities, SDK paths and arbitrary properties from active and closed projections', async () => {
  const raw = { ...rawActive(), owner_id: 'SECRET OWNER', place_reference: 'PRIVATE HOME', canary: 'SERVER KEY' };
  const repository = new SupabaseCaseRepository({ rawCase: async () => raw });
  const value = await repository.read(slug);
  const json = JSON.stringify(value);
  for (const secret of ['SECRET OWNER', 'PRIVATE HOME', 'SERVER KEY', photo.path, photo.bucket, 'owner_id', 'photo_objects']) assert.equal(json.includes(secret), false);
  assert.equal(value.photoCount, 1); assert.equal(value.name, 'Luna'); assert.equal(value.revision.length, 64);
  assert.deepEqual(await new SupabaseCaseRepository({ rawCase: async () => ({ ...raw, state: 'closed', resolution: 'resolved', closed_at: null }) }).read(slug), { state: 'closed', resolution: 'resolved', closedAt: null });
  assert.throws(() => publicCase({ ...active(), area: { latitude: -12.05001, longitude: -77.04 } }), ReaderFailure);
  assert.throws(() => publicCase({ ...active(), photoCount: 0 }), ReaderFailure);
});

test('Photos revalidate revocation after Storage and reject upstream path/bucket injection', async () => {
  let calls = 0; let downloads = 0;
  const repository = new SupabaseCaseRepository({ rawCase: async () => ++calls === 1 ? rawActive() : { state: 'unavailable' }, photo: async () => { downloads++; return new Uint8Array([255, 216, 255, 217]); } });
  await assert.rejects(repository.photo(slug, 0), { kind: 'not_found' }); assert.equal(downloads, 1);
  for (const invalid of [{ bucket: 'pet-photo-originals', path: photo.path }, { bucket: photo.bucket, path: '../secret.jpg' }]) {
    const invalidRepository = new SupabaseCaseRepository({ rawCase: async () => ({ ...rawActive(), photo_objects: [invalid] }), photo() { throw new Error('must not download'); } });
    await assert.rejects(invalidRepository.photo(slug, 0), { kind: 'not_found' });
  }
});

test('Source uses proper secret/legacy headers, bounded payloads, timeout and safe SDK failures', async () => {
  let options;
  const source = new SupabaseCaseDataSource({ url: 'https://backend.example.test', key: 'sb_secret_test-server-key', fetchImpl: async (_, input) => { options = input; return new Response(JSON.stringify(rawActive())); } });
  await source.rawCase(slug);
  assert.equal(options.headers.apikey, 'sb_secret_test-server-key'); assert.equal(options.headers.Authorization, undefined);
  assert.equal(options.redirect, 'error'); assert.deepEqual(JSON.parse(options.body), { p_slug: slug });
  const jwt = new SupabaseCaseDataSource({ url: '', key: 'eyJ.test.signature', fetchImpl: async (_, input) => { options = input; return new Response('{}'); } });
  await jwt.rawCase(slug); assert.equal(options.headers.Authorization, 'Bearer eyJ.test.signature');
  for (const fetchImpl of [async () => { throw new Error('secret SDK response'); }, async () => new Response('a'.repeat(33000)), async () => new Response('{}', { status: 403 })]) {
    await assert.rejects(new SupabaseCaseDataSource({ url: '', key: '', fetchImpl }).rawCase(slug), (error) => error instanceof ReaderFailure && !error.message.includes('secret'));
  }
  await assert.rejects(new SupabaseCaseDataSource({ url: '', key: '', fetchImpl: async () => new Response('bad', { headers: { 'Content-Type': 'image/jpeg' } }) }).photo(photo.bucket, photo.path), ReaderFailure);
});

test('Browser repository distinguishes neutral, rate limiting and offline without propagating server details', async () => {
  assert.deepEqual(await new HttpCaseRepository(async () => ({ state: 'unavailable' })).read(slug), { state: 'unavailable' });
  await assert.rejects(new HttpCaseRepository(async () => { throw new ReaderFailure('rate_limited'); }).read(slug), { kind: 'rate_limited' });
  await assert.rejects(new HttpCaseRepository(async () => { throw new Error('SDK PRIVATE'); }).read(slug), { kind: 'unavailable' });
});

test('ViewModel deduplicates, retains unchanged content, recovers offline, clears a revoked case and ignores stale routes', async () => {
  let resolve; let calls = 0; let next = active();
  const model = new ReaderViewModel({ execute: async () => { calls++; if (resolve) return new Promise((done) => { resolve = done; }); if (next instanceof Error) throw next; return next; } });
  const states = []; model.subscribe((state) => states.push(state));
  await model.load(slug); const original = model.state.value;
  next = { ...active() }; await model.load(slug); assert.equal(model.state.value, original);
  next = new ReaderFailure(); await model.load(slug); assert.equal(model.state.value, original); assert.equal(model.state.notice, 'unavailable');
  next = { state: 'unavailable' }; await model.load(slug); assert.equal(model.state.phase, 'unavailable'); assert.equal(model.state.value.name, undefined);
  resolve = true; const pending = model.load(slug); const finish = resolve;
  await model.load(slug); assert.equal(calls, 5);
  resolve = null; next = { state: 'closed', resolution: 'resolved', closedAt: null }; await model.load('c'.repeat(64));
  finish(active()); await pending; assert.equal(model.state.phase, 'closed'); model.dispose();
  assert.ok(states.some((state) => state.refreshing && state.value === original));
});
