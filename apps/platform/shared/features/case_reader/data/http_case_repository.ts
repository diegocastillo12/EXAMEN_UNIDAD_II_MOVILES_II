import { publicCase, ReaderFailure } from '../domain/case.ts';
import type { CaseRepository } from '../domain/read_case.ts';
export type CaseFetch = (path: string, options: RequestInit) => Promise<unknown>;
export class HttpCaseRepository implements CaseRepository {
  private readonly fetcher: CaseFetch;
  constructor(fetcher?: CaseFetch) {
    this.fetcher = fetcher || (async (path, options) => {
      const response = await globalThis.fetch(path, options);
      if (response.status === 404) return { state: 'unavailable' };
      if (!response.ok) throw new ReaderFailure(response.status === 429 ? 'rate_limited' : 'unavailable');
      return response.json();
    });
  }
  async read(slug: string, signal?: AbortSignal) {
    try { return publicCase(await this.fetcher(`/api/c/${slug}`, { signal, cache: 'no-store', credentials: 'omit' })); }
    catch (error) { if (signal?.aborted) throw error; throw error instanceof ReaderFailure ? error : new ReaderFailure(); }
  }
}
