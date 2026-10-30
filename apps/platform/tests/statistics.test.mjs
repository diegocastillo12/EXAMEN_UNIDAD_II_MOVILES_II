import assert from 'node:assert/strict';
import { test } from 'node:test';
import { StatisticsFailure, statisticsPeriod, ReadStatisticsAccess, ReadPilotStatistics } from '../shared/features/statistics/domain/statistics.ts';
import { statisticsDto } from '../shared/features/statistics/data/statistics_dto.ts';
import { HttpStatisticsRepository } from '../shared/features/statistics/data/http_statistics_repository.ts';
import { StatisticsSource } from '../server/features/statistics/data/statistics_source.ts';
import { ServerStatisticsRepository } from '../server/features/statistics/data/server_statistics_repository.ts';
import { StatisticsViewModel } from '../shared/features/statistics/presentation/statistics_view_model.ts';
const result = (period = { from: '2026-10-01', to: '2026-10-24' }) => ({ period, timezone: 'America/Lima', publishedLost: 4, publishedFound: 2, sightings: 8, recovered: 1, cancelled: 0, archived: 1, reports: 3 });
test('HU16.1 exact calendar validation and bounded inclusive periods', () => {
 for (const [from, to] of [['2026-02-29', '2026-03-01'], ['2026-02-30', '2026-03-01'], ['2026-1-01', '2026-01-02'], ['2026-10-25', '2026-10-24'], ['2024-01-01', '2025-01-01'], [null, '2026-01-01'], ['1999-12-31', '2000-01-01']]) assert.throws(() => statisticsPeriod(from, to), e => e.kind === 'invalid');
 assert.deepEqual(statisticsPeriod('2024-01-01', '2024-12-31'), { from: '2024-01-01', to: '2024-12-31' });
});
test('HU16.1 DTO strips private fields and rejects unsafe aggregates', () => {
 assert.deepEqual(statisticsDto({ ...result(), email: 'PRIVATE', coordinates: [-12, -77] }), result());
 for (const value of [-1, 1.5, '3', Number.MAX_SAFE_INTEGER + 1]) assert.throws(() => statisticsDto({ ...result(), recovered: value }), e => e.kind === 'unavailable');
 assert.throws(() => statisticsDto({ ...result(), timezone: 'UTC' }), e => e.kind === 'unavailable');
});
test('HU16.1 retained refresh, accurate queried dates, retry and revocation clearing', async () => {
 let failure, release;
 const repository = { canRead: async () => true, read: async period => { if (release) await release; if (failure) throw new StatisticsFailure(failure); return result(period); } };
 const model = new StatisticsViewModel(new ReadStatisticsAccess(repository), new ReadPilotStatistics(repository), '2026-10-24');
 await model.load(); assert.equal(model.state.data.publishedLost, 4);
 model.edit('from', '2026-10-10'); failure = 'unavailable'; await model.load();
 assert.equal(model.state.data.period.from, '2026-10-01'); assert.equal(model.state.failure, 'unavailable');
 failure = null; await model.load(); assert.equal(model.state.data.period.from, '2026-10-10');
 failure = 'forbidden'; await model.load(); assert.equal(model.state.data, null); assert.equal(model.state.allowed, false);
 failure = null; await model.load(); assert.ok(model.state.data);
 let resume; release = new Promise(r => resume = r); const pending = model.load(); model.invalidate(); resume(); await pending; assert.equal(model.state.data, null);
 release = null; await model.load(); model.dispose(); assert.equal(model.state.data, null);
});
test('HU16.1 one request while busy and disposal discards pending results', async () => {
 let resume, calls = 0; const barrier = new Promise(r => resume = r);
 const repository = { canRead: async () => true, read: async period => { calls++; await barrier; return result(period); } };
 const model = new StatisticsViewModel(new ReadStatisticsAccess(repository), new ReadPilotStatistics(repository), '2026-10-24');
 const pending = model.load(); await model.load(); model.edit('to', '2026-10-22'); assert.equal(calls, 1); assert.equal(model.state.to, '2026-10-24'); model.dispose(); resume(); await pending; assert.equal(model.state.data, null);
});
test('HU16.1 HTTP account binding, sanitized failures and matching period', async () => {
 let request;
 const repository = new HttpStatisticsRepository('actor', async (path, init) => { request = { path, init }; return new Response(JSON.stringify(result())); });
 await repository.read(result().period); assert.equal(request.path, '/api/statistics/read'); assert.equal(request.init.headers['X-Account-Actor'], 'actor'); assert.equal(request.init.cache, 'no-store');
 await assert.rejects(repository.read({ from: '2026-09-01', to: '2026-09-02' }), e => e.kind === 'unavailable');
 for (const [status, kind] of [[401, 'unauthenticated'], [403, 'forbidden'], [409, 'conflict'], [422, 'invalid'], [503, 'unavailable']]) await assert.rejects(new HttpStatisticsRepository('actor', async () => new Response('PRIVATE', { status })).canRead(), e => e.kind === kind);
});
test('HU16.1 backend uses caller JWT, bounds payloads and checks independent permission', async () => {
 const source = new StatisticsSource({ url: 'http://backend.test', key: 'publishable' }, 'private-jwt', async (path, init) => {
  assert.equal(init.headers.Authorization, 'Bearer private-jwt'); assert.equal(init.redirect, 'error');
  return new Response(JSON.stringify(path.endsWith('require_platform_administrator') ? 'actor' : result()));
 });
 const repository = new ServerStatisticsRepository(source, 'actor'); assert.equal(await repository.canRead(), true); assert.deepEqual(await repository.read(result().period), result());
 const denied = new StatisticsSource({ url: 'http://backend.test', key: 'publishable' }, 'jwt', async () => new Response(JSON.stringify({ code: '42501', message: 'PRIVATE' }), { status: 403 }));
 assert.equal(await new ServerStatisticsRepository(denied, 'actor').canRead(), false);
 await assert.rejects(new ServerStatisticsRepository(denied, 'actor').read(result().period), e => e.kind === 'forbidden');
 await assert.rejects(new StatisticsSource({ url: 'http://backend.test', key: 'publishable' }, 'jwt', async () => new Response('x'.repeat(16385))).rpc('read_pilot_statistics', {}), e => e.kind === 'unavailable');
});
