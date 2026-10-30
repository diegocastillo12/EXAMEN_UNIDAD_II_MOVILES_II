export type CaseArea = Readonly<{ latitude: number; longitude: number }>;
export type ActiveCase = Readonly<{
  state: 'active'; kind: 'lost' | 'found'; name: string;
  species: 'dog' | 'cat' | 'other'; speciesDetail: string | null;
  size: 'small' | 'medium' | 'large' | null; sex: 'male' | 'female' | null;
  traits: string; occurredAt: string; photoCount: number; revision: string; area: CaseArea;
}>;
export type PublicCase = ActiveCase | Readonly<{ state: 'closed'; resolution: 'resolved'; closedAt: string | null }> | Readonly<{ state: 'unavailable' }>;
export const validSlug = (value: unknown): value is string => typeof value === 'string' && /^[0-9a-f]{64}$/.test(value);
export class ReaderFailure extends Error {
  constructor(readonly kind = 'unavailable') { super(kind); this.name = 'ReaderFailure'; }
}
export function record(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new ReaderFailure();
  return value as Record<string, unknown>;
}
function text(value: unknown, limit: number): string {
  if (typeof value !== 'string' || [...value].length > limit) throw new ReaderFailure();
  return value;
}
function date(value: unknown): string {
  if (typeof value !== 'string' || value.length > 40 || !Number.isFinite(Date.parse(value))) throw new ReaderFailure();
  return new Date(value).toISOString();
}
export function publicCase(input: unknown): PublicCase {
  const value = record(input);
  if (value.state === 'unavailable') return Object.freeze({ state: 'unavailable' });
  if (value.state === 'closed' && value.resolution === 'resolved') return Object.freeze({
    state: 'closed', resolution: 'resolved', closedAt: value.closedAt == null ? null : date(value.closedAt),
  });
  const area = record(value.area);
  if (value.state !== 'active' || (value.kind !== 'lost' && value.kind !== 'found') ||
    (value.species !== 'dog' && value.species !== 'cat' && value.species !== 'other') ||
    (value.size !== null && value.size !== 'small' && value.size !== 'medium' && value.size !== 'large') ||
    (value.sex !== null && value.sex !== 'male' && value.sex !== 'female') ||
    typeof value.photoCount !== 'number' || !Number.isInteger(value.photoCount) || value.photoCount < 1 || value.photoCount > 3 ||
    typeof value.revision !== 'string' || !/^[0-9a-f]{64}$/.test(value.revision) ||
    typeof area.latitude !== 'number' || !Number.isFinite(area.latitude) || Math.abs(area.latitude) > 85 ||
    typeof area.longitude !== 'number' || !Number.isFinite(area.longitude) || Math.abs(area.longitude) > 180 ||
    [area.latitude, area.longitude].some(n => Math.abs(n * 100 - Math.round(n * 100)) > 1e-7)) throw new ReaderFailure();
  return Object.freeze({ state: 'active', kind: value.kind, name: text(value.name, 80),
    species: value.species, speciesDetail: value.speciesDetail == null ? null : text(value.speciesDetail, 60),
    size: value.size, sex: value.sex, traits: text(value.traits, 200), occurredAt: date(value.occurredAt),
    photoCount: value.photoCount, revision: value.revision,
    area: Object.freeze({ latitude: area.latitude, longitude: area.longitude }),
  });
}
