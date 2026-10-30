export type SightingPoint = Readonly<{ latitude: number; longitude: number; source: 'manual' | 'gps'; accuracy: number | null }>;
export type SightingDraft = Readonly<{ id: string; observedAt: string; point: SightingPoint | null; comment: string; photo: Uint8Array | null }>;
export type SightingReceipt = Readonly<{ id: string; receivedAt: string; late: boolean }>;
export class SightingFailure extends Error {
  constructor(readonly kind: 'invalid' | 'unavailable' | 'closed' | 'rate_limited' | 'photo' | 'conflict' | 'location' | 'blocked', readonly fields: readonly string[] = []) {
    super(kind); this.name = 'SightingFailure';
  }
}
export interface SightingRepository { submit(slug: string, draft: SightingDraft): Promise<SightingReceipt> }
export interface SightingLocationRepository { current(): Promise<SightingPoint> }
export class LocateSighting {
  constructor(private readonly repository: SightingLocationRepository) {}
  async execute(): Promise<SightingPoint> {
    try {
      const point = await this.repository.current();
      if (!Number.isFinite(point.latitude) || Math.abs(point.latitude) > 85 || !Number.isFinite(point.longitude) || Math.abs(point.longitude) > 180 || point.source !== 'gps' || typeof point.accuracy !== 'number' || !Number.isFinite(point.accuracy) || point.accuracy < 0 || point.accuracy > 100000) throw Error();
      return Object.freeze({ ...point });
    } catch { throw new SightingFailure('location'); }
  }
}
export function validateSighting(draft: SightingDraft, now: number): void {
  const fields: string[] = [];
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(draft.id)) fields.push('id');
  const observed = Date.parse(draft.observedAt);
  if (!Number.isFinite(observed) || observed < Date.UTC(2000, 0, 1) || observed > now) fields.push('observedAt');
  const p = draft.point;
  if (!p || !Number.isFinite(p.latitude) || Math.abs(p.latitude) > 85 || !Number.isFinite(p.longitude) || Math.abs(p.longitude) > 180 ||
    !['manual', 'gps'].includes(p.source) || (p.source === 'manual' ? p.accuracy !== null : typeof p.accuracy !== 'number' || !Number.isFinite(p.accuracy) || p.accuracy < 0 || p.accuracy > 100000)) fields.push('point');
  if (typeof draft.comment !== 'string' || [...draft.comment.trim()].length > 500) fields.push('comment');
  if (draft.photo && (draft.photo.length === 0 || draft.photo.length > 8388608)) fields.push('photo');
  if (fields.length) throw new SightingFailure('invalid', fields);
}
export class SubmitSighting {
  constructor(private readonly repository: SightingRepository, private readonly now: () => number = Date.now) {}
  execute(slug: string, draft: SightingDraft) {
    if (!/^[0-9a-f]{64}$/.test(slug)) throw new SightingFailure('closed');
    validateSighting(draft, this.now());
    return this.repository.submit(slug, draft);
  }
}
