import { StatisticsFailure } from '../../../../shared/features/statistics/domain/statistics.ts';
export class StatisticsSource {
  constructor(private readonly config: { url: string; key: string }, private readonly token: string, private readonly fetcher: typeof fetch = fetch) {}
  async rpc(name: 'require_platform_administrator' | 'read_pilot_statistics', params: unknown): Promise<unknown> {
    try {
      const response = await this.fetcher(this.config.url + '/rest/v1/rpc/' + name, {
        method: 'POST', headers: { apikey: this.config.key, Authorization: 'Bearer ' + this.token, 'Content-Type': 'application/json' },
        body: JSON.stringify(params), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(15000),
      });
      const reader = response.body?.getReader(); if (!reader) throw new StatisticsFailure('unavailable');
      const chunks: Uint8Array[] = []; let size = 0;
      try { while (true) { const { done, value } = await reader.read(); if (done) break; size += value.length; if (size > 16384) throw new StatisticsFailure('unavailable'); chunks.push(value); } }
      finally { await reader.cancel().catch(() => {}); }
      const value = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      if (!response.ok) throw new StatisticsFailure(response.status === 401 ? 'unauthenticated' : value.code === '42501' || response.status === 403 ? 'forbidden' : value.message === 'statistics_invalid' ? 'invalid' : 'unavailable');
      return value;
    } catch (error) { throw error instanceof StatisticsFailure ? error : new StatisticsFailure('unavailable'); }
  }
}
