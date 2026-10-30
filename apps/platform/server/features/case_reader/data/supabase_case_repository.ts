import { createHash } from 'node:crypto';
import { publicCase, ReaderFailure, record } from '../../../../shared/features/case_reader/domain/case.ts';
import type { CaseRepository, CasePhotoRepository } from '../../../../shared/features/case_reader/domain/read_case.ts';
export type PhotoObject = { bucket: string; path: string };
export interface CaseSource {
  rawCase(slug: string, signal?: AbortSignal): Promise<unknown>;
  photo(bucket: string, path: string, signal?: AbortSignal): Promise<Uint8Array>;
}
const uuid = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
const safePath = new RegExp(`^${uuid}/${uuid}/${uuid}\\.jpg$`);
function safePhoto(value: unknown): value is PhotoObject {
  if (!value || typeof value !== 'object') return false;
  const photo = value as Record<string, unknown>;
  return typeof photo.bucket === 'string' && ['pet-photo-renditions', 'found-photo-renditions'].includes(photo.bucket) && typeof photo.path === 'string' && safePath.test(photo.path);
}
function photoAt(input: unknown, index: number) {
  const raw = record(input);
  return raw.state === 'active' && Array.isArray(raw.photo_objects) ? raw.photo_objects[index] : null;
}
export class SupabaseCaseRepository implements CaseRepository, CasePhotoRepository {
  constructor(private readonly source: CaseSource) {}
  async read(slug: string, signal?: AbortSignal) {
    const raw = record(await this.source.rawCase(slug, signal));
    if (raw.state === 'unavailable') return publicCase(raw);
    if (raw.state === 'closed') return publicCase({ state: 'closed', resolution: raw.resolution, closedAt: raw.closed_at });
    if (!Array.isArray(raw.photo_objects) || !raw.photo_objects.every(safePhoto)) throw new ReaderFailure();
    return publicCase({ state: raw.state, kind: raw.kind, name: raw.name, species: raw.species,
      speciesDetail: raw.species_detail, size: raw.size, sex: raw.sex, traits: raw.traits,
      occurredAt: raw.occurred_at, area: raw.area, photoCount: raw.photo_objects.length,
      revision: createHash('sha256').update(JSON.stringify(raw)).digest('hex') });
  }
  async photo(slug: string, index: number, signal?: AbortSignal) {
    const photo = photoAt(await this.source.rawCase(slug, signal), index);
    if (!safePhoto(photo)) throw new ReaderFailure('not_found');
    const bytes = await this.source.photo(photo.bucket, photo.path, signal);
    const next = photoAt(await this.source.rawCase(slug, signal), index);
    if (!safePhoto(next) || next.bucket !== photo.bucket || next.path !== photo.path) throw new ReaderFailure('not_found');
    return bytes;
  }
}
