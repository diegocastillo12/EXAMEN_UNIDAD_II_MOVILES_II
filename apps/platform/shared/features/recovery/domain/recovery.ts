export type RecoveryIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable' | 'photo' | 'blocked';
export class RecoveryFailure extends Error {
  constructor(readonly kind: RecoveryIssue, readonly fields: readonly string[] = []) { super(kind); }
}
export type Species = 'dog' | 'cat' | 'other';
export type Pet = Readonly<{ id: string; name: string; species: Species; speciesDetail: string | null; size: string | null; sex: string | null; ageMonths: number | null; traits: string; version: number; photoIds: readonly string[]; archived: boolean }>;
export type PetDraft = Omit<Pet, 'photoIds' | 'archived'>;
export type CaseCard = Readonly<{ id: string; source: 'lost' | 'found'; name: string; species: string; traits: string; kind: string; reportKind: string; status: string; occurredAt: string; latitude: number; longitude: number; hasPhoto: boolean }>;
export type CasePage = Readonly<{ items: readonly CaseCard[]; cursor: string | null }>;
export type CasePublication = CaseCard & Readonly<{ photos: number; size: string | null; sex: string | null; custody: string | null }>;
export type ExploreQuery = Readonly<{ kind: string; species: string; status: string }>;
export type ReportKind = 'own_loss' | 'possible_loss' | 'independent_found' | 'sighting' | 'with_reporter';
export type ReportDraft = Readonly<{ id: string; kind: ReportKind; petId: string | null; petVersion: number | null; targetId: string | null; communityTarget: boolean; occurredAt: string; latitude: number | null; longitude: number | null; place: string; species: string; speciesDetail: string; size: string; sex: string; traits: string; photoIds: readonly string[]; custody?: 'with_me' | 'not_with_me' | null }>;
export type ReportPhoto = Readonly<{ id: string; bytes: Uint8Array }>;
export type ReportReceipt = Readonly<{ id: string; status: string }>;
export type LocalReportDraft = Readonly<{ draft:ReportDraft;photos:readonly ReportPhoto[];frozen:boolean }>;
export interface ReportDraftRepository { read():Promise<LocalReportDraft|null>; save(value:LocalReportDraft):Promise<void>; clear():Promise<void>; }
export class ReadReportDraft { constructor(private readonly repository:ReportDraftRepository) {} execute() { return this.repository.read(); } }
export class SaveReportDraft {
  constructor(private readonly repository:ReportDraftRepository) {}
  execute(value:LocalReportDraft) { if (!isId(value.draft.id) || value.photos.length > 3 || value.photos.some(p => !isId(p.id) || p.bytes.length > 8388608)) throw new RecoveryFailure('invalid'); return this.repository.save(value); }
}
export class ClearReportDraft { constructor(private readonly repository:ReportDraftRepository) {} execute() { return this.repository.clear(); } }
export interface RecoveryRepository {
  publication(source: 'lost'|'found',id: string): Promise<CasePublication>;
  explore(query: ExploreQuery, cursor: string | null): Promise<CasePage>;
  pets(): Promise<readonly Pet[]>;
  savePet(draft: PetDraft): Promise<Pet>;
  uploadPetPhoto(pet: string, photo: ReportPhoto): Promise<void>;
  targets(): Promise<readonly CaseCard[]>;
  publish(draft: ReportDraft, photos: readonly ReportPhoto[]): Promise<ReportReceipt>;
}
export class ReadCasePublication {
  constructor(private readonly repository: RecoveryRepository) {}
  execute(source: 'lost'|'found',id:string) { if(!['lost','found'].includes(source)||!isId(id))throw new RecoveryFailure('invalid');return this.repository.publication(source,id); }
}
export const isId = (value: unknown): value is string => typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
const length = (value: unknown, max: number) => typeof value === 'string' && [...value.trim()].length >= 1 && [...value.trim()].length <= max;
export function validatePet(d: PetDraft): PetDraft {
  if (!d || typeof d !== 'object' || Array.isArray(d)) throw new RecoveryFailure('invalid');
  const fields = [];
  if (!isId(d.id) || !Number.isInteger(d.version) || d.version < 0) fields.push('id');
  if (!length(d.name, 80)) fields.push('name');
  if (!['dog','cat','other'].includes(d.species)) fields.push('species');
  if (d.species === 'other' && !length(d.speciesDetail, 60)) fields.push('speciesDetail');
  if (!['small','medium','large'].includes(d.size || '')) fields.push('size');
  if (d.sex !== null && !['male','female'].includes(d.sex)) fields.push('sex');
  if (!Number.isInteger(d.ageMonths) || d.ageMonths! < 0 || d.ageMonths! > 600) fields.push('ageMonths');
  if (!length(d.traits, 200)) fields.push('traits');
  if (fields.length) throw new RecoveryFailure('invalid', fields);
  return { ...d, name: d.name.trim(), traits: d.traits.trim(), speciesDetail: d.species === 'other' ? d.speciesDetail!.trim() : null };
}
export class ExploreCases {
  constructor(private readonly repository: RecoveryRepository) {}
  execute(query: ExploreQuery, cursor: string | null = null) {
    if (!query || !['all','lost','found','sighting'].includes(query.kind) || !['all','dog','cat','other'].includes(query.species) || !['all','active','resolved'].includes(query.status) || (cursor !== null && (typeof cursor !== 'string' || cursor.length > 2048))) throw new RecoveryFailure('invalid');
    return this.repository.explore(query, cursor);
  }
}
export class ReadMyPets { constructor(private readonly repository: RecoveryRepository) {} execute() { return this.repository.pets(); } }
export class SaveMyPet { constructor(private readonly repository: RecoveryRepository) {} execute(draft: PetDraft) { return this.repository.savePet(validatePet(draft)); } }
export class AddPetPhoto {
  constructor(private readonly repository: RecoveryRepository) {}
  execute(pet: string, photo: ReportPhoto) { if (!isId(pet) || !isId(photo.id) || !photo.bytes.length || photo.bytes.length > 8388608) throw new RecoveryFailure('photo'); return this.repository.uploadPetPhoto(pet, photo); }
}
export class ReadOpenSearches { constructor(private readonly repository: RecoveryRepository) {} execute() { return this.repository.targets(); } }
export function validateReport(d: ReportDraft, photos: readonly ReportPhoto[], now = Date.now()): ReportDraft {
  if (!d || typeof d !== 'object' || Array.isArray(d) || !Array.isArray(photos) || ['place','traits','species','speciesDetail','size','sex'].some(key => typeof (d as unknown as Record<string,unknown>)[key] !== 'string')) throw new RecoveryFailure('invalid');
  const fields = [];
  if (!isId(d.id) || !['own_loss','possible_loss','independent_found','sighting','with_reporter'].includes(d.kind)) fields.push('kind');
  if (typeof d.occurredAt !== 'string' || !Number.isFinite(Date.parse(d.occurredAt)) || Date.parse(d.occurredAt) > now || Date.parse(d.occurredAt) < Date.UTC(2000,0,1)) fields.push('occurredAt');
  if (typeof d.latitude !== 'number' || !Number.isFinite(d.latitude) || Math.abs(d.latitude) > 85 || typeof d.longitude !== 'number' || !Number.isFinite(d.longitude) || Math.abs(d.longitude) > 180) fields.push('point');
  if (!length(d.place, 120)) fields.push('place');
  if (!Array.isArray(d.photoIds) || d.photoIds.length > 3 || d.photoIds.some(id => !isId(id)) || new Set(d.photoIds).size !== d.photoIds.length) fields.push('photos');
  if (d.custody !== undefined && d.custody !== null && !['with_me','not_with_me'].includes(d.custody)) fields.push('custody');
  if (d.kind === 'own_loss') { if (!isId(d.petId) || !Number.isInteger(d.petVersion) || d.petVersion! < 1) fields.push('pet'); if (!d.photoIds?.length || photos.length) fields.push('photos'); }
  else {
    if (!['possible_loss','independent_found'].includes(d.kind) && !isId(d.targetId)) fields.push('target');
    if (['possible_loss','independent_found'].includes(d.kind) && (d.targetId !== null || d.communityTarget !== false)) fields.push('target');
    if (['possible_loss','independent_found'].includes(d.kind) && (!['dog','cat','other'].includes(d.species) || (d.species === 'other' && !length(d.speciesDetail, 40)))) fields.push('species');
    if (d.size && !['small','medium','large'].includes(d.size)) fields.push('size');
    if (d.sex && !['male','female'].includes(d.sex)) fields.push('sex');
    if (!length(d.traits, 200)) fields.push('traits');
    if (['possible_loss','independent_found'].includes(d.kind) && !photos.length) fields.push('photos');
    if (photos.length > 3 || photos.length !== d.photoIds?.length || photos.some(p => !isId(p.id) || !d.photoIds.includes(p.id) || !(p.bytes instanceof Uint8Array) || !p.bytes.length || p.bytes.length > 8388608) || new Set(photos.map(p => p.id)).size !== photos.length) fields.push('photos');
  }
  if (fields.length) throw new RecoveryFailure('invalid', fields);
  return { ...d, place: d.place.trim(), traits: d.traits.trim(), speciesDetail: d.speciesDetail.trim() };
}
export class PublishRecoveryReport {
  constructor(private readonly repository: RecoveryRepository) {}
  execute(draft: ReportDraft, photos: readonly ReportPhoto[]) { return this.repository.publish(validateReport(draft, photos), photos); }
}
