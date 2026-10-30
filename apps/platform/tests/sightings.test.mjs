import assert from 'node:assert/strict';
import { test } from 'node:test';
import sharp from 'sharp';
import { Readable } from 'node:stream';
import { sightingRequest, maxSightingBody } from '../server/infrastructure/sighting_request.ts';
import { SubmitSighting, LocateSighting, SightingFailure, validateSighting } from '../shared/features/sightings/domain/sighting.ts';
import { SightingViewModel } from '../shared/features/sightings/presentation/sighting_view_model.ts';
import { processEvidence } from '../server/features/sightings/data/evidence_processor.ts';
import { SupabaseSightingRepository } from '../server/features/sightings/data/supabase_sighting_repository.ts';
import { SupabaseSightingDataSource } from '../server/features/sightings/data/supabase_sighting_data_source.ts';
const slug = 'a'.repeat(64);
const draft = () => ({ id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', observedAt: '2026-01-01T01:00:00Z', point: { latitude: -12.05, longitude: -77.04, source: 'manual', accuracy: null }, comment: 'Por el parque', photo: null });
const receipt = { id: draft().id, receivedAt: '2026-10-18T01:00:00Z', late: true };
test('Sighting domain rejects future/missing points/invalid GPS/oversized text and evidence before writes', async () => {
  let writes = 0; const submit = new SubmitSighting({ submit: async () => { writes++; return receipt; } }, () => Date.parse('2026-10-18T00:00:00Z'));
  for (const bad of [{ observedAt: '2100-01-01' }, { point: null }, { point: { latitude: NaN, longitude: 0, source: 'manual', accuracy: null } }, { point: { latitude: 0, longitude: 0, source: 'gps', accuracy: null } }, { comment: 'x'.repeat(501) }, { photo: new Uint8Array(8388609) }]) {
    assert.throws(() => submit.execute(slug, { ...draft(), ...bad }), SightingFailure);
  }
  assert.equal(writes, 0); assert.deepEqual(await submit.execute(slug, draft()), receipt);
  validateSighting({ ...draft(), point: { latitude: -12, longitude: -77, source: 'gps', accuracy: 500 } }, Date.now());
});
test('ViewModel blocks double submission, preserves exact ambiguous payload and confirms only a saved receipt', async () => {
  let resolve; let calls = []; let attempt = 0;
  const model = new SightingViewModel(new SubmitSighting({ submit: async (_, value) => { calls.push(value); if (++attempt === 1) return new Promise(r => { resolve = r; }); if (attempt === 2) throw new SightingFailure('unavailable'); return receipt; } }), slug);
  const first = model.send(draft()); await model.send(draft()); assert.equal(calls.length, 1); assert.equal(model.state.receipt, null);
  resolve(receipt); await first; assert.deepEqual(model.state.receipt, receipt);
  await model.send(draft()); assert.equal(calls.length, 1);
  const retry = new SightingViewModel(new SubmitSighting({ submit: async (_, value) => { calls.push(value); if (++attempt === 2) throw new SightingFailure('unavailable'); return receipt; } }), slug);
  await retry.send(draft()); assert.equal(retry.state.locked, true);
  await retry.send({ ...draft(), comment: 'changed after timeout' }); assert.equal(calls.at(-1).comment, draft().comment); assert.deepEqual(retry.state.receipt, receipt);
  let notified = 0; retry.subscribe(() => notified++); retry.dispose(); const old = notified; await retry.send(draft()); assert.equal(notified, old);
});
test('Evidence processor decodes and recodes bytes, removing EXIF and rejecting spoofed/animated/oversized files', async () => {
  const original = await sharp({ create: { width: 1500, height: 900, channels: 3, background: '#111' } }).withExif({ IFD0: { Artist: 'PRIVATE CAMERA METADATA' } }).jpeg().toBuffer();
  assert.ok((await sharp(original).metadata()).exif);
  const clean = await processEvidence(original); const metadata = await sharp(clean).metadata();
  assert.equal(metadata.format, 'jpeg'); assert.equal(metadata.exif, undefined); assert.equal(metadata.xmp, undefined); assert.equal(metadata.width, 1280); assert.ok(clean.length <= 1048576);
  assert.equal(await processEvidence(null), null);
  for (const bad of [Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"/>'), Buffer.from('not an image'), new Uint8Array(8388609)]) await assert.rejects(processEvidence(bad), error => error.kind === 'photo');
  const pixels = Buffer.alloc(24); for (let n = 0; n < 8; n++) pixels[n * 3 + (n < 4 ? 0 : 2)] = 255;
  const animated = await sharp(pixels, { raw: { width: 2, height: 4, channels: 3, pageHeight: 2 } }).webp({ loop: 0, delay: [100,100] }).toBuffer();
  assert.equal((await sharp(animated).metadata()).pages, 2);
  await assert.rejects(processEvidence(animated), error => error.kind === 'photo');
});
test('Multipart request parser bounds chunked bodies and rejects invalid or duplicated metadata', async () => {
  const oversized = Readable.from([Buffer.alloc(maxSightingBody + 1)]); oversized.headers = { 'content-type': 'multipart/form-data; boundary=test' };
  await assert.rejects(sightingRequest(oversized), error => error.kind === 'invalid');
  const form = new FormData(); form.set('report', JSON.stringify(draft())); form.append('report', '{}');
  const request = new Request('https://example.test', { method: 'POST', body: form });
  const duplicate = Readable.from([Buffer.from(await request.arrayBuffer())]); duplicate.headers = { 'content-type': request.headers.get('content-type') };
  await assert.rejects(sightingRequest(duplicate), error => error.kind === 'invalid');
});
test('Location denial keeps the manual option and a late GPS result cannot replace a newer manual point', async () => {
  let resolve;
  const manual = draft().point;
  const model = new SightingViewModel(new SubmitSighting({ submit: async () => receipt }), slug, new LocateSighting({ current: () => new Promise(r => { resolve = r; }) }));
  const pending = model.locate(); assert.equal(model.state.locating, true);
  model.choosePoint(manual); resolve({ latitude: 1, longitude: 1, source: 'gps', accuracy: 50 }); await pending;
  assert.deepEqual(model.state.point, manual); assert.equal(model.state.locating, false);
  const denied = new SightingViewModel(new SubmitSighting({ submit: async () => receipt }), slug, new LocateSighting({ current: async () => { throw Error('PRIVATE PLATFORM ERROR'); } }));
  await denied.locate(); assert.equal(denied.state.failure.kind, 'location'); denied.choosePoint(manual); assert.deepEqual(denied.state.point, manual);
});
test('Server repository sends only sanitized evidence and deterministic retry hash; SDK failures remain safe', async () => {
  const calls = []; const repo = new SupabaseSightingRepository({ submit: async value => { calls.push(value); return { ...receipt, secret: 'never return' }; } }, 'd'.repeat(64));
  assert.deepEqual(await repo.submit(slug, draft()), receipt); await repo.submit(slug, draft());
  assert.equal(calls[0].p_request_hash, calls[1].p_request_hash); assert.equal(calls[0].p_evidence, null);
  const source = new SupabaseSightingDataSource({ url: 'https://example.test', key: 'sb_secret_not-real' }, async () => new Response(JSON.stringify({ message: 'PRIVATE SDK MESSAGE' }), { status: 500 }));
  await assert.rejects(source.submit({}), error => error.kind === 'unavailable' && !error.message.includes('PRIVATE'));
});
