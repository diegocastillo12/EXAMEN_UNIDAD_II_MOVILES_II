export type CaseRef = Readonly<{ source: 'lost' | 'found'; id: string }>;
export type MatchIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable' | 'busy';
export class MatchFailure extends Error {
  constructor(readonly kind: MatchIssue) { super(kind); }
}
export const matchModel = Object.freeze({
  id: 'Xenova/clip-vit-base-patch32', revision: 'd15189d7028b43f1d3e65039190477f6af591c2a',
  version: 'clip-vit-b32-d15189d-q8-v1', dimensions: 512,
});
export type MatchPhoto = Readonly<{ id: string; path: string; hash: string; embedding: readonly number[] | null }>;
export type MatchCase = Readonly<{
  ref: CaseRef; revision: string; name: string; species: string; occurredAt: string;
  latitude: number; longitude: number; photos: readonly MatchPhoto[];
}>;
export type MatchReview = 'confirmed' | 'dismissed';
export type MatchSearch = Readonly<{ ref: CaseRef; name: string; species: string }>;
export type MatchCandidate = Readonly<{
  ref: CaseRef; revision: string; name: string; distanceMeters: number; daysApart: number;
  review: MatchReview | null;
}>;
export type MatchResult = Readonly<{
  anchor: CaseRef; revision: string; model: string; candidates: readonly MatchCandidate[];
  pendingPhotos: number; complete: boolean;
}>;
export type ReviewCommand = Readonly<{
  id: string; anchor: CaseRef; anchorRevision: string; candidate: CaseRef;
  candidateRevision: string; decision: MatchReview; model: string;
}>;
export interface MatchingRepository {
  searches(): Promise<readonly MatchSearch[]>;
  search(ref: CaseRef): Promise<MatchResult>;
  review(command: ReviewCommand): Promise<void>;
}
export interface ImageEncoder { encode(bytes: Uint8Array): Promise<readonly number[]>; }
export const matchId = (value: unknown): value is string => typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
export function caseRef(value: CaseRef): CaseRef {
  if (!value || !['lost', 'found'].includes(value.source) || !matchId(value.id)) throw new MatchFailure('invalid');
  return { source: value.source, id: value.id };
}
export function unitEmbedding(value: readonly number[]): readonly number[] {
  if (!Array.isArray(value) || value.length !== matchModel.dimensions || value.some(x => !Number.isFinite(x))) throw new MatchFailure('unavailable');
  const norm = Math.hypot(...value);
  if (!Number.isFinite(norm) || norm < 1e-8) throw new MatchFailure('unavailable');
  return Object.freeze(value.map(x => x / norm));
}
export class FindCaseMatches {
  constructor(private readonly repository: MatchingRepository) {}
  execute(ref: CaseRef) { return this.repository.search(caseRef(ref)); }
}
export class ReadMatchSearches {
  constructor(private readonly repository: MatchingRepository) {}
  execute() { return this.repository.searches(); }
}
export class ReviewCaseMatch {
  constructor(private readonly repository: MatchingRepository) {}
  execute(command: ReviewCommand) {
    if (!command || !matchId(command.id) || !['confirmed','dismissed'].includes(command.decision) ||
      command.model !== matchModel.version || !/^[0-9a-f]{32}$/.test(command.anchorRevision) || !/^[0-9a-f]{32}$/.test(command.candidateRevision)) throw new MatchFailure('invalid');
    const anchor = caseRef(command.anchor), candidate = caseRef(command.candidate);
    if (anchor.id === candidate.id && anchor.source === candidate.source) throw new MatchFailure('invalid');
    return this.repository.review({ ...command, anchor, candidate });
  }
}
function distance(a: MatchCase, b: MatchCase) {
  const rad = Math.PI / 180, lat = (b.latitude-a.latitude)*rad, lon = (b.longitude-a.longitude)*rad;
  const h = Math.sin(lat/2)**2 + Math.cos(a.latitude*rad)*Math.cos(b.latitude*rad)*Math.sin(lon/2)**2;
  return 6371000*2*Math.asin(Math.sqrt(Math.max(0, Math.min(1,h))));
}
/** A ranking for review, never an identity probability. Missing photos cannot rank. */
export function rankMatches(anchor: MatchCase, cases: readonly MatchCase[]): readonly Readonly<{ item: MatchCase; score: number; distanceMeters: number; daysApart: number }>[] {
  const anchorVectors = anchor.photos.filter(p => p.embedding).map(p => unitEmbedding(p.embedding!));
  if (!anchorVectors.length) return [];
  const ranked = [];
  for (const item of cases) {
    if (item.species !== anchor.species || (item.ref.source === anchor.ref.source && item.ref.id === anchor.ref.id)) continue;
    const vectors = item.photos.filter(p => p.embedding).map(p => unitEmbedding(p.embedding!));
    if (!vectors.length) continue;
    // Each case contributes one result, independent of its photograph count.
    const visual = Math.max(...anchorVectors.flatMap(a => vectors.map(b => a.reduce((s,v,i) => s+v*b[i]!,0))));
    const distanceMeters = distance(anchor,item), daysApart = Math.abs(Date.parse(anchor.occurredAt)-Date.parse(item.occurredAt))/86400000;
    // Wide, soft geography/time signals: transport and delayed reporting remain possible.
    const score = .85*visual + .10*Math.exp(-distanceMeters/50000) + .05*Math.exp(-daysApart/90);
    ranked.push({ item, score, distanceMeters: Math.round(distanceMeters), daysApart: Math.round(daysApart) });
  }
  return ranked.sort((a,b) => b.score-a.score || a.item.ref.source.localeCompare(b.item.ref.source) || a.item.ref.id.localeCompare(b.item.ref.id)).slice(0,5);
}
