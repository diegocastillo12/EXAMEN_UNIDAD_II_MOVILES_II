import { validSlug, ReaderFailure } from './case.ts';
import type { PublicCase } from './case.ts';
export interface CaseRepository { read(slug: string, signal?: AbortSignal): Promise<PublicCase> }
export interface CasePhotoRepository { photo(slug: string, index: number, signal?: AbortSignal): Promise<Uint8Array> }
export class ReadCase {
  constructor(private readonly repository: CaseRepository) {}
  async execute(slug: unknown, signal?: AbortSignal): Promise<PublicCase> {
    if (!validSlug(slug)) return Object.freeze({ state: 'unavailable' });
    return this.repository.read(slug, signal);
  }
}
export class ReadCasePhoto {
  constructor(private readonly repository: CasePhotoRepository) {}
  async execute(slug: unknown, index: number, signal?: AbortSignal): Promise<Uint8Array> {
    if (!validSlug(slug) || !Number.isInteger(index) || index < 0 || index > 2) throw new ReaderFailure('not_found');
    return this.repository.photo(slug, index, signal);
  }
}
