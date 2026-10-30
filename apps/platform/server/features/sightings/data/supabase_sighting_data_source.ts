import { SightingFailure } from '../../../../shared/features/sightings/domain/sighting.ts';
import type { SightingSource } from './supabase_sighting_repository.ts';
export class SupabaseSightingDataSource implements SightingSource {
  constructor(private readonly config: { url: string; key: string }, private readonly fetcher: typeof fetch = fetch,
    private readonly rpc = 'submit_public_sighting', private readonly mapPayload: (payload: Record<string, unknown>) => Record<string, unknown> = value => value) {}
  async submit(payload: Record<string, unknown>): Promise<unknown> {
    const headers: Record<string, string> = { apikey: this.config.key, 'Content-Type': 'application/json' };
    if (this.config.key.startsWith('eyJ')) headers.Authorization = `Bearer ${this.config.key}`;
    try {
      const response = await this.fetcher(`${this.config.url}/rest/v1/rpc/${this.rpc}`, {
        method: 'POST', headers, body: JSON.stringify(this.mapPayload(payload)), redirect: 'error', cache: 'no-store', signal: AbortSignal.timeout(15000),
      });
      // RPC output is small. Bound responses even if the upstream proxy misbehaves.
      const reader = response.body?.getReader(); if (!reader) throw new SightingFailure('unavailable');
      let text = ''; const decoder = new TextDecoder(); let count = 0;
      try { while (true) { const { done, value } = await reader.read(); if (done) break; count += value.length; if (count > 8192) throw new SightingFailure('unavailable'); text += decoder.decode(value, { stream: true }); } }
      finally { await reader.cancel().catch(() => {}); }
      const value = JSON.parse(text + decoder.decode());
      if (!response.ok) {
        const kinds = { interaction_blocked:'blocked',sighting_invalid: 'invalid', sighting_closed: 'closed', sighting_conflict: 'conflict', sighting_rate_limited: 'rate_limited' } as const;
        throw new SightingFailure(kinds[value.message as keyof typeof kinds] || 'unavailable');
      }
      return value;
    } catch (error) { throw error instanceof SightingFailure ? error : new SightingFailure('unavailable'); }
  }
}
