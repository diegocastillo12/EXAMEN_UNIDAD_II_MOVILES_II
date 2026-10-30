import { BlockFailure } from '../domain/user_blocks.ts';
import type { UserBlockRepository,BlockTarget,BlockChange } from '../domain/user_blocks.ts';
import { blockEntry,blockPage } from './user_block_dto.ts';
export class HttpUserBlockRepository implements UserBlockRepository {
  constructor(private readonly actor:string,private readonly fetcher:typeof fetch=(input,init)=>globalThis.fetch(input,init)) {}
  private async call(path:string,body?:unknown) {
    try {
      const response=await this.fetcher('/api/user-blocks/'+path,{method:body===undefined?'GET':'POST',credentials:'same-origin',cache:'no-store',headers:{'X-Account-Actor':this.actor,...(body===undefined?{}:{'Content-Type':'application/json'})},...(body===undefined?{}:{body:JSON.stringify(body)}),signal:AbortSignal.timeout(30000)});
      if (!response.ok) {await response.body?.cancel();throw new BlockFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':response.status===409?'conflict':response.status===422?'invalid':'unavailable');}
      return await response.json();
    } catch(e) {throw e instanceof BlockFailure?e:new BlockFailure('unavailable');}
  }
  async list(before:string|null) {return blockPage(await this.call('list'+(before?'?before='+encodeURIComponent(before):'')));}
  async prepare(target:BlockTarget) {const raw=await this.call('prepare',target);return raw?.entry===null?null:blockEntry(raw?.entry);}
  async set(change:BlockChange) {
    const row=blockEntry(await this.call('set',{id:change.entry.id,enabled:change.enabled,version:change.entry.version}));
    if (row.id!==change.entry.id || row.enabled!==change.enabled || row.version!==change.entry.version+(change.entry.enabled===change.enabled?0:1)) throw new BlockFailure('unavailable');
    return row;
  }
}
