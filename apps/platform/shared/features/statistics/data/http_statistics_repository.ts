import { StatisticsFailure } from '../domain/statistics.ts';
import type { StatisticsRepository, StatisticsPeriod } from '../domain/statistics.ts';
import { statisticsDto } from './statistics_dto.ts';
export class HttpStatisticsRepository implements StatisticsRepository {
  constructor(private readonly actor: string, private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init)) {}
  private async call(path: string, body?: unknown): Promise<unknown> {
    try {
      const response = await this.fetcher('/api/statistics/' + path, {
        method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { 'X-Account-Actor': this.actor, ...(body === undefined ? {} : { 'Content-Type': 'application/json' }) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), signal: AbortSignal.timeout(20000),
      });
      if (!response.ok) {
        await response.body?.cancel();
        throw new StatisticsFailure(response.status === 401 ? 'unauthenticated' : response.status === 403 ? 'forbidden' : response.status === 409 ? 'conflict' : response.status === 422 ? 'invalid' : 'unavailable');
      }
      return await response.json();
    } catch (error) { throw error instanceof StatisticsFailure ? error : new StatisticsFailure('unavailable'); }
  }
  async canRead() {
    const value = await this.call('access') as { allowed?: unknown };
    if (typeof value?.allowed !== 'boolean') throw new StatisticsFailure('unavailable');
    return value.allowed;
  }
  async read(period: StatisticsPeriod) {
    const result = statisticsDto(await this.call('read', period));
    if (result.period.from !== period.from || result.period.to !== period.to) throw new StatisticsFailure('unavailable');
    return result;
  }
}
