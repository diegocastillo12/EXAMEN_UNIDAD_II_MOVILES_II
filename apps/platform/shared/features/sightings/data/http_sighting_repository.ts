import { SightingFailure } from '../domain/sighting.ts';
import type { SightingDraft, SightingReceipt, SightingRepository } from '../domain/sighting.ts';
export class HttpSightingRepository implements SightingRepository {
  async submit(slug: string, draft: SightingDraft): Promise<SightingReceipt> {
    const body = new FormData();
    body.set('report', JSON.stringify({ ...draft, photo: undefined }));
    if (draft.photo) body.set('photo', new Blob([new Uint8Array(draft.photo)], { type: 'application/octet-stream' }), 'evidence');
    try {
      const response = await fetch(`/api/c/${slug}/sightings`, { method: 'POST', body, credentials: 'omit', redirect: 'error', signal: AbortSignal.timeout(30000) });
      const value = await response.json();
      if (!response.ok) throw new SightingFailure(response.status === 423 ? 'blocked' : response.status === 429 ? 'rate_limited' : response.status === 409 ? (value.error === 'conflict' ? 'conflict' : 'closed') : response.status === 400 || response.status === 413 ? 'invalid' : response.status === 422 ? 'photo' : 'unavailable', Array.isArray(value.fields) ? value.fields : []);
      if (value.id !== draft.id || typeof value.receivedAt !== 'string' || !Number.isFinite(Date.parse(value.receivedAt)) || typeof value.late !== 'boolean') throw new SightingFailure('unavailable');
      return Object.freeze({ id: value.id, receivedAt: value.receivedAt, late: value.late });
    } catch (error) { throw error instanceof SightingFailure ? error : new SightingFailure('unavailable'); }
  }
}
