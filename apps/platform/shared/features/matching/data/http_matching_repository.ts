import { MatchFailure, caseRef, matchModel, matchId } from '../domain/matching.ts';
import type { MatchingRepository, CaseRef, MatchResult, ReviewCommand, MatchSearch } from '../domain/matching.ts';
export function matchResult(value: unknown): MatchResult {
  const r=value as MatchResult;
  if(!r||r.model!==matchModel.version||!/^[a-f0-9]{32}$/.test(r.revision)||typeof r.complete!=='boolean'||!Number.isInteger(r.pendingPhotos)||r.pendingPhotos<0||r.pendingPhotos>303||!Array.isArray(r.candidates)||r.candidates.length>5)throw new MatchFailure('unavailable');
  caseRef(r.anchor);
  for(const c of r.candidates){caseRef(c.ref);if(!/^[a-f0-9]{32}$/.test(c.revision)||typeof c.name!=='string'||c.name.length>80||!Number.isInteger(c.distanceMeters)||c.distanceMeters<0||!Number.isInteger(c.daysApart)||c.daysApart<0||![null,'confirmed','dismissed'].includes(c.review))throw new MatchFailure('unavailable');}
  return {anchor:caseRef(r.anchor),revision:r.revision,model:r.model,pendingPhotos:r.pendingPhotos,complete:r.complete,candidates:r.candidates.map(c=>({ref:caseRef(c.ref),revision:c.revision,name:c.name,distanceMeters:c.distanceMeters,daysApart:c.daysApart,review:c.review}))};
}
export class HttpMatchingRepository implements MatchingRepository {
  constructor(private readonly actor:string,private readonly fetcher:typeof fetch=(input,init)=>globalThis.fetch(input,init)){}
  private async call(path:string,body:unknown={}) {
    try{
      const response=await this.fetcher('/api/matching/'+path,{method:'POST',credentials:'same-origin',cache:'no-store',headers:{'Content-Type':'application/json','X-Account-Actor':this.actor},body:JSON.stringify(body),signal:AbortSignal.timeout(90000)});
      const reader=response.body?.getReader();if(!reader)throw new MatchFailure('unavailable');
      const chunks:Uint8Array[]=[];let size=0;
      try{while(true){const{done,value}=await reader.read();if(done)break;size+=value.length;if(size>131072)throw new MatchFailure('unavailable');chunks.push(value);}}finally{await reader.cancel().catch(()=>{});}
      if(!response.ok)throw new MatchFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':response.status===409?'conflict':response.status===422?'invalid':response.status===429?'busy':'unavailable');
      const joined=new Uint8Array(size);let offset=0;for(const chunk of chunks){joined.set(chunk,offset);offset+=chunk.length;}
      return JSON.parse(new TextDecoder().decode(joined));
    }catch(error){throw error instanceof MatchFailure?error:new MatchFailure('unavailable');}
  }
  async searches():Promise<readonly MatchSearch[]>{
    const rows=await this.call('searches');if(!Array.isArray(rows)||rows.length>100)throw new MatchFailure('unavailable');
    return rows.map(r=>{if(!r||!matchId(r.ref?.id)||typeof r.name!=='string'||!['dog','cat','other'].includes(r.species))throw new MatchFailure('unavailable');return{ref:caseRef(r.ref),name:r.name,species:r.species};});
  }
  async search(ref:CaseRef){return matchResult(await this.call('search',ref));}
  async review(command:ReviewCommand){const value=await this.call('review',command);if(value?.saved!==true)throw new MatchFailure('unavailable');}
}
