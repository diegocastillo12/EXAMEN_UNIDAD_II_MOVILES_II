import { MatchFailure } from '../../../../shared/features/matching/domain/matching.ts';
export class MatchingSource {
  constructor(private readonly config: { url: string; key: string }, private readonly fetcher: typeof fetch = fetch) {}
  private async request(path: string, body?: unknown): Promise<Uint8Array> {
    try {
      const response = await this.fetcher(this.config.url + path, {
        method: body === undefined ? 'GET' : 'POST',
        headers: { apikey: this.config.key, Authorization: 'Bearer ' + this.config.key, ...(body === undefined ? {} : { 'Content-Type': 'application/json' }) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(15000),
      });
      const reader = response.body?.getReader();
      const chunks: Uint8Array[] = []; let size = 0;
      if (reader) try { while (true) { const { done, value } = await reader.read(); if (done) break; size += value.length; if (size > 4194304) throw new MatchFailure('unavailable'); chunks.push(value); } }
      finally { await reader.cancel().catch(() => {}); }
      const bytes = Buffer.concat(chunks);
      if (!response.ok) {
        let code = ''; try { code = JSON.parse(bytes.toString('utf8')).code || ''; } catch { /* No upstream messages leave data. */ }
        throw new MatchFailure(code === '42501' ? 'forbidden' : code === 'PT409' ? 'conflict' : code === '22023' ? 'invalid' : code === '54000' ? 'busy' : 'unavailable');
      }
      return bytes;
    } catch (error) { throw error instanceof MatchFailure ? error : new MatchFailure('unavailable'); }
  }
  async rpc(name: 'list_my_match_searches' | 'read_case_match_context' | 'store_case_match_embedding' | 'review_case_match', params: unknown): Promise<unknown> {
    const bytes = await this.request('/rest/v1/rpc/' + name,params);
    try { return bytes.length ? JSON.parse(Buffer.from(bytes).toString('utf8')) : null; }
    catch { throw new MatchFailure('unavailable'); }
  }
  photo(source: 'lost' | 'found', path: string) {
    if (!/^[0-9a-f-]{36}\/[0-9a-f-]{36}\/[0-9a-f-]{36}\.jpg$/i.test(path)) throw new MatchFailure('unavailable');
    return this.request('/storage/v1/object/authenticated/' + (source === 'lost' ? 'pet-photo-renditions/' : 'found-photo-renditions/') + path);
  }
}
