import sharp from 'sharp';
import { RecoveryFailure, isId } from '../../../../shared/features/recovery/domain/recovery.ts';
import type { RecoveryRepository, CaseCard, CasePage, Pet, PetDraft, ExploreQuery, ReportDraft, ReportPhoto } from '../../../../shared/features/recovery/domain/recovery.ts';
import { RecoverySource } from './recovery_source.ts';
type Row = Record<string, any>;
const rows = (v: unknown): Row[] => { if (!Array.isArray(v) || v.some(r => !r || typeof r !== 'object' || Array.isArray(r))) throw new RecoveryFailure('unavailable'); return v; };
function card(r: Row, source = r.source): CaseCard {
  if (!isId(r.id) || !['lost','found'].includes(source)) throw new RecoveryFailure('unavailable');
  return { id: r.id, source, name: String(r.name || r.pet_name || ''), species: String(r.species || ''), traits: String(r.traits || ''), kind: String(r.kind || (source === 'lost' || r.report_kind === 'possible_loss' ? 'lost' : r.report_kind === 'sighting' ? 'sighting' : 'found')), reportKind: String(r.report_kind || 'own_loss'), status: String(r.status || 'active'), occurredAt: String(r.occurred_at || ''), latitude: Number(r.latitude ?? r.public_latitude), longitude: Number(r.longitude ?? r.public_longitude), hasPhoto: !!r.cover_path || (Array.isArray(r.photos) && r.photos.length > 0) };
}
function pet(r: Row, actor: string): Pet {
  if (!isId(r.id) || r.owner_id !== actor || !['dog','cat','other'].includes(r.species) || !Number.isInteger(r.version)) throw new RecoveryFailure('unavailable');
  return { id: r.id, name: r.name, species: r.species, speciesDetail: r.species_detail ?? null, size: r.size ?? null, sex: r.sex ?? null, ageMonths: r.age_months ?? null, traits: r.traits || '', version: r.version, archived: !!r.archived_at, photoIds: (Array.isArray(r.pet_photos) ? r.pet_photos : []).filter((p: Row) => p.status === 'published' && p.processed_at && isId(p.id)).sort((a: Row,b: Row) => Number(!!b.is_primary)-Number(!!a.is_primary) || String(a.created_at).localeCompare(String(b.created_at))).map((p: Row) => p.id) };
}
async function image(bytes: Uint8Array) {
  try { if (!bytes.length || bytes.length > 8388608) throw Error(); const input = sharp(bytes, { limitInputPixels: 24000000, failOn: 'warning', animated: false }); const m = await input.metadata(); if (!['jpeg','png','webp'].includes(m.format || '') || (m.pages || 1) > 1) throw Error(); return await input.rotate().resize(1600,1600,{ fit:'inside',withoutEnlargement:true }).flatten({ background:'#fff' }).jpeg({ quality:85 }).timeout({ seconds:5 }).toBuffer(); }
  catch { throw new RecoveryFailure('photo'); }
}
export class ServerRecoveryRepository implements RecoveryRepository {
  constructor(private readonly source: RecoverySource, private readonly actor: string) {}
  async publication(source:'lost'|'found',id:string) {
    if(!isId(id))throw new RecoveryFailure('invalid');
    const row=rows(await this.source.rpc(source==='lost'?'read_recovery_pet_case':'read_recovery_report',{p_id:id}))[0];
    if(!row)throw new RecoveryFailure('forbidden');
    return {...card(row,source),photos:Array.isArray(row.photos)?Math.min(3,row.photos.length):0,size:row.size??null,sex:row.sex??null,custody:row.custody??null};
  }
  async explore(query: ExploreQuery, cursor: string | null): Promise<CasePage> {
    let after = null; try { after = cursor ? JSON.parse(cursor) : null; } catch { throw new RecoveryFailure('invalid'); }
    const result = await this.source.rpc('explore_cases', { p_kind: query.kind, p_species: query.species, p_status: query.status, p_cursor: after, p_limit: 20 }) as Row;
    if (!result || !Array.isArray(result.items)) throw new RecoveryFailure('unavailable');
    return { items: rows(result.items).map(r => card(r)), cursor: result.next_cursor ? JSON.stringify(result.next_cursor) : null };
  }
  async pets() { return rows(await this.source.petRows(this.actor)).map(r => pet(r,this.actor)); }
  async savePet(d: PetDraft) {
    const result = rows(await this.source.rpc(d.version === 0 ? 'create_pet_v2' : 'update_pet_v2', { p_id:d.id,p_name:d.name,p_species:d.species,p_species_detail:d.speciesDetail,p_size:d.size,p_sex:d.sex,p_age_months:d.ageMonths,p_traits:d.traits,...(d.version ? { p_expected_version:d.version } : {}) }));
    if (result.length !== 1 || result[0]!.id !== d.id) throw new RecoveryFailure('unavailable');
    // Reload published photos; an update never erases the existing gallery.
    return (await this.pets()).find(p => p.id === d.id) || pet(result[0]!, this.actor);
  }
  async uploadPetPhoto(parent: string, p: ReportPhoto) {
    const result = await this.source.processPhoto(parent,p.id,await image(p.bytes)) as Row;
    if (!result || result.id !== p.id || result.pet_id !== parent || result.owner_id !== this.actor || result.status !== 'published' || !result.processed_at) throw new RecoveryFailure('unavailable');
  }
  async targets() {
    const result = rows(await this.source.rpc('list_open_recovery_searches'));
    return result.map(r => card(r, r.community === true || r.community_target === true ? 'found' : 'lost'));
  }
  async publish(d: ReportDraft, photos: readonly ReportPhoto[]) {
    const base = { p_id:d.id,p_occurred_at:d.occurredAt,p_latitude:d.latitude,p_longitude:d.longitude,p_place_reference:d.place,p_photo_ids:d.photoIds };
    let result;
    if (d.kind === 'own_loss') result = await this.source.rpc('publish_lost_case', { ...base,p_pet_id:d.petId,p_pet_version:d.petVersion });
    else {
      // Validate/decode all images before creating a server draft.
      const prepared = []; for (const p of photos) prepared.push({ id:p.id,bytes:await image(p.bytes) });
      await this.source.rpc('prepare_recovery_report', { p_id:d.id,p_photo_ids:d.photoIds,p_report_kind:d.kind,p_target_id:d.targetId,p_community_target:d.communityTarget });
      for (const p of prepared) {
        const row = await this.source.processPhoto(d.id,p.id,p.bytes,true) as Row;
        if (!row || row.id !== p.id || row.case_id !== d.id || row.owner_id !== this.actor || row.status !== 'ready' || !row.processed_at) throw new RecoveryFailure('unavailable');
      }
      result = await this.source.rpc('publish_recovery_report', { ...base,p_report_kind:d.kind,p_target_id:d.targetId,p_community_target:d.communityTarget,p_species:d.species,p_species_detail:['possible_loss','independent_found'].includes(d.kind) && d.species === 'other' ? d.speciesDetail : null,p_size:d.size || null,p_sex:d.sex || null,p_traits:d.traits,p_custody:d.kind === 'independent_found' ? d.custody ?? null : null });
    }
    const row = rows(result)[0]; if (!row || row.id !== d.id || row.owner_id !== this.actor || row.status !== 'active') throw new RecoveryFailure('unavailable');
    return { id:row.id as string,status:row.status as string };
  }
  async photo(source: string, id: string, index: number) {
    if (!isId(id) || !['lost','found','pet'].includes(source) || !Number.isInteger(index) || index < 0 || index > 2) throw new RecoveryFailure('invalid');
    let path: string | undefined, bucket: string;
    if (source === 'pet') {
      const ownerPet = (await this.pets()).find(p => p.id === id), photo = ownerPet?.photoIds[index];
      if (photo) path = this.actor + '/' + id + '/' + photo + '.jpg'; bucket = 'pet-photo-renditions';
    } else {
      const row = rows(await this.source.rpc(source === 'lost' ? 'read_recovery_pet_case' : 'read_recovery_report', { p_id:id }))[0];
      path = row?.photos?.[index]?.path; bucket = source === 'lost' ? 'pet-photo-renditions' : 'found-photo-renditions';
    }
    if (typeof path !== 'string' || !/^[0-9a-f-]{36}\/[0-9a-f-]{36}\/[0-9a-f-]{36}\.jpg$/i.test(path)) throw new RecoveryFailure('forbidden');
    return this.source.photo(bucket,path);
  }
}
