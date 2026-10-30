import { AppealFailure } from '../../../../shared/features/appeals/domain/appeals.ts';
export class AppealsSource {
  constructor(private readonly config: { url: string; key: string }, private readonly token: string, private readonly fetcher: typeof fetch = fetch) {}
  async rpc(name: string, params: unknown) {
    try {
      const response = await this.fetcher(this.config.url + '/rest/v1/rpc/' + name, { method: 'POST', headers: { apikey: this.config.key, Authorization: 'Bearer ' + this.token, 'Content-Type': 'application/json' },
        body: JSON.stringify(params), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(15000) });
      const reader = response.body?.getReader(); if (!reader) throw new AppealFailure('unavailable');
      const chunks: Uint8Array[] = []; let size = 0;
      try { while (true) { const { done, value } = await reader.read(); if (done) break; size += value.length; if (size > 262144) throw new AppealFailure('unavailable'); chunks.push(value); } }
      finally { await reader.cancel().catch(() => {}); }
      const value = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      if (!response.ok) throw new AppealFailure(response.status === 401 ? 'unauthenticated' : value.message === 'appeal_conflict' ? 'conflict' : value.message === 'appeal_invalid' ? 'invalid' : response.status === 403 || value.code === '42501' ? 'forbidden' : 'unavailable');
      return value;
    } catch (error) { throw error instanceof AppealFailure ? error : new AppealFailure('unavailable'); }
  }
}
