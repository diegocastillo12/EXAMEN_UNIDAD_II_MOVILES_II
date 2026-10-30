import { MatchFailure, caseRef, matchModel, matchId, unitEmbedding, rankMatches } from '../../../../shared/features/matching/domain/matching.ts';
import type { MatchingRepository, ImageEncoder, CaseRef, MatchCase, MatchReview, ReviewCommand, MatchResult } from '../../../../shared/features/matching/domain/matching.ts';
import { MatchingSource } from './matching_source.ts';
type Context = { anchor: MatchCase; candidates: readonly MatchCase[]; reviews: readonly { ref: CaseRef; revision: string; decision: MatchReview }[] };
function record(value: unknown): Record<string,unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new MatchFailure('unavailable');
  return value as Record<string,unknown>;
}
function snapshot(value: unknown): MatchCase {
  const r = record(value), ref = caseRef({ source: r.source as 'lost'|'found', id: r.id as string });
  if (typeof r.revision !== 'string' || !/^[a-f0-9]{32}$/.test(r.revision) || typeof r.name !== 'string' || r.name.length>80 ||
    !['dog','cat','other'].includes(String(r.species)) || typeof r.occurred_at !== 'string' || !Number.isFinite(Date.parse(r.occurred_at)) ||
    typeof r.latitude !== 'number' || !Number.isFinite(r.latitude) || Math.abs(r.latitude)>85 || typeof r.longitude !== 'number' || !Number.isFinite(r.longitude) || Math.abs(r.longitude)>180 ||
    !Array.isArray(r.photos) || r.photos.length<1 || r.photos.length>3) throw new MatchFailure('unavailable');
  return { ref, revision: r.revision, name: r.name, species: String(r.species), occurredAt: r.occurred_at, latitude:r.latitude, longitude:r.longitude,
    photos:r.photos.map(value => {
      const p = record(value);
      if (!matchId(p.id) || typeof p.path !== 'string' || !/^[a-f0-9-]{36}\/[a-f0-9-]{36}\/[a-f0-9-]{36}\.jpg$/.test(p.path) || typeof p.hash!=='string' || !/^[a-f0-9]{64}$/.test(p.hash)) throw new MatchFailure('unavailable');
      return { id:p.id,path:p.path,hash:p.hash,embedding:p.embedding===null ? null : unitEmbedding(p.embedding as number[]) };
    }) };
}
function context(value: unknown): Context {
  const r = record(value);
  if (!Array.isArray(r.candidates) || r.candidates.length>100 || !Array.isArray(r.reviews) || r.reviews.length>100) throw new MatchFailure('unavailable');
  return { anchor:snapshot(r.anchor),candidates:r.candidates.map(snapshot), reviews:r.reviews.map(value=>{
    const v=record(value);
    if (!['confirmed','dismissed'].includes(String(v.decision)) || typeof v.revision!=='string') throw new MatchFailure('unavailable');
    return { ref:caseRef({source:v.source as 'lost'|'found',id:v.id as string}),revision:v.revision,decision:v.decision as MatchReview };
  }) };
}
export class ServerMatchingRepository implements MatchingRepository {
  constructor(private readonly source: MatchingSource, private readonly encoder: ImageEncoder, private readonly actor: string, private readonly maxPhotos=6) {}
  async searches() {
    const value=await this.source.rpc('list_my_match_searches',{p_actor:this.actor});
    if (!Array.isArray(value) || value.length>100) throw new MatchFailure('unavailable');
    return value.map(row=>{
      const r=record(row);
      if (typeof r.name!=='string'||!['dog','cat','other'].includes(String(r.species)))throw new MatchFailure('unavailable');
      return {ref:caseRef({source:r.source as 'lost'|'found',id:r.id as string}),name:r.name,species:String(r.species)};
    });
  }
  private async context(ref: CaseRef) {
    const value = context(await this.source.rpc('read_case_match_context',{p_actor:this.actor,p_source:ref.source,p_case:ref.id}));
    if (value.anchor.ref.source!==ref.source || value.anchor.ref.id!==ref.id) throw new MatchFailure('unavailable');
    return value;
  }
  async search(ref: CaseRef): Promise<MatchResult> {
    const initial = await this.context(ref);
    let remaining = this.maxPhotos;
    // Explicit bounded work per request. Retrying continues from durable indexes.
    for (const item of [initial.anchor,...initial.candidates]) for (const photo of item.photos) {
      if (photo.embedding || remaining<=0) continue;
      --remaining;
      const embedding = await this.encoder.encode(await this.source.photo(item.ref.source,photo.path));
      await this.source.rpc('store_case_match_embedding',{p_actor:this.actor,p_source:item.ref.source,p_case:item.ref.id,p_revision:item.revision,p_photo:photo.id,p_hash:photo.hash,p_embedding:embedding});
    }
    // Re-read permissions, photos, lifecycle, reviews and persisted indexes after work.
    const current = await this.context(ref);
    const pendingPhotos = [current.anchor,...current.candidates].reduce((n,c)=>n+c.photos.filter(p=>!p.embedding).length,0);
    const candidates = rankMatches(current.anchor,current.candidates).map(({item,distanceMeters,daysApart})=>({
      ref:item.ref,revision:item.revision,name:item.name,distanceMeters,daysApart,
      review:current.reviews.find(r=>r.ref.source===item.ref.source&&r.ref.id===item.ref.id&&r.revision===item.revision)?.decision??null,
    }));
    return {anchor:ref,revision:current.anchor.revision,model:matchModel.version,candidates,pendingPhotos,complete:pendingPhotos===0};
  }
  async review(c: ReviewCommand) {
    await this.source.rpc('review_case_match',{p_actor:this.actor,p_command:c.id,p_source:c.anchor.source,p_case:c.anchor.id,p_revision:c.anchorRevision,
      p_candidate_source:c.candidate.source,p_candidate:c.candidate.id,p_candidate_revision:c.candidateRevision,p_decision:c.decision});
  }
}
