import { createHash } from 'node:crypto';
import { SightingFailure } from '../../../../shared/features/sightings/domain/sighting.ts';
import type { SightingDraft, SightingReceipt, SightingRepository } from '../../../../shared/features/sightings/domain/sighting.ts';
import { processEvidence } from './evidence_processor.ts';
export interface SightingSource { submit(payload: Record<string, unknown>): Promise<unknown> }
export class SupabaseSightingRepository implements SightingRepository {
  constructor(private readonly source: SightingSource, private readonly actorHash: string) {}
  async submit(slug: string, draft: SightingDraft): Promise<SightingReceipt> {
    const photoHash = draft.photo ? createHash('sha256').update(draft.photo).digest('hex') : null;
    const report = { id: draft.id.toLowerCase(), observedAt: new Date(draft.observedAt).toISOString(),
      point: { latitude: draft.point!.latitude, longitude: draft.point!.longitude, source: draft.point!.source, accuracy: draft.point!.accuracy }, comment: draft.comment.trim() };
    const requestHash = createHash('sha256').update(JSON.stringify({ slug, ...report, photoHash })).digest('hex');
    const evidence = await processEvidence(draft.photo);
    const raw = await this.source.submit({ p_slug: slug, p_report: report, p_request_hash: requestHash, p_actor_hash: this.actorHash, p_evidence: evidence?.toString('base64') ?? null });
    if (!raw || typeof raw !== 'object') throw new SightingFailure('unavailable');
    const value = raw as Record<string, unknown>;
    if (value.id !== report.id || typeof value.receivedAt !== 'string' || !Number.isFinite(Date.parse(value.receivedAt)) || typeof value.late !== 'boolean') throw new SightingFailure('unavailable');
    return Object.freeze({ id: value.id as string, receivedAt: value.receivedAt, late: value.late });
  }
}
