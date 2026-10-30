import { ReaderFailure } from '../../../../shared/features/case_reader/domain/case.ts';
import type { CaseSource } from './supabase_case_repository.ts';
async function limitedBytes(response: Response, limit: number) {
  const reader = response.body?.getReader(); if (!reader) throw new ReaderFailure();
  const chunks: Uint8Array[] = []; let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read(); if (done) break;
      size += value.length; if (size > limit) throw new ReaderFailure(); chunks.push(value);
    }
  } finally { await reader.cancel().catch(() => {}); }
  const bytes = new Uint8Array(size); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  return bytes;
}
export class SupabaseCaseDataSource implements CaseSource {
  private readonly url: string;
  private readonly headers: Record<string, string>;
  private readonly fetcher: typeof fetch;
  constructor({ url, key, fetchImpl = fetch }: { url: string; key: string; fetchImpl?: typeof fetch }) {
    this.url = url; this.fetcher = fetchImpl; this.headers = { apikey: key };
    if (key.startsWith('eyJ')) this.headers.Authorization = `Bearer ${key}`;
  }
  async rawCase(slug: string, signal?: AbortSignal): Promise<unknown> {
    try {
      const response = await this.fetcher(`${this.url}/rest/v1/rpc/read_qr_case`, {
        method: 'POST', headers: { ...this.headers, 'Content-Type': 'application/json' },
        body: JSON.stringify({ p_slug: slug }), redirect: 'error', cache: 'no-store',
        signal: AbortSignal.any([AbortSignal.timeout(5000), ...(signal ? [signal] : [])]),
      });
      if (!response.ok) throw new ReaderFailure();
      return JSON.parse(new TextDecoder().decode(await limitedBytes(response, 32768)));
    } catch { throw new ReaderFailure(); }
  }
  async photo(bucket: string, path: string, signal?: AbortSignal) {
    try {
      const response = await this.fetcher(`${this.url}/storage/v1/object/authenticated/${bucket}/${path}`, {
        headers: this.headers, redirect: 'error', cache: 'no-store',
        signal: AbortSignal.any([AbortSignal.timeout(5000), ...(signal ? [signal] : [])]),
      });
      if (!response.ok || response.headers.get('content-type')?.split(';')[0] !== 'image/jpeg') throw new ReaderFailure();
      const bytes = await limitedBytes(response, 2097152);
      if (bytes.length < 4 || bytes[0] !== 255 || bytes[1] !== 216 || bytes.at(-2) !== 255 || bytes.at(-1) !== 217) throw new ReaderFailure();
      return bytes;
    } catch { throw new ReaderFailure(); }
  }
}
