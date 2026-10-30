import { InboxFailure } from '../domain/inbox.ts';
import type { InboxRepository } from '../domain/inbox.ts';
import { inboxDto } from './inbox_dto.ts';
export class HttpInboxRepository implements InboxRepository {
  constructor(private readonly actor:string,private readonly fetcher:typeof fetch=(input,init)=>globalThis.fetch(input,init)) {}
  private async call(path:string,body?:unknown) {
    try {
      const response=await this.fetcher('/api/notifications/'+path,{method:body===undefined?'GET':'POST',credentials:'same-origin',cache:'no-store',headers:{'X-Account-Actor':this.actor,...(body===undefined?{}:{'Content-Type':'application/json'})},...(body===undefined?{}:{body:JSON.stringify(body)}),signal:AbortSignal.timeout(30000)});
      if (!response.ok) {await response.body?.cancel();throw new InboxFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':response.status===409?'conflict':response.status===422?'invalid':'unavailable');}
      return await response.json();
    } catch(e) {throw e instanceof InboxFailure?e:new InboxFailure('unavailable');}
  }
  async list(cursor:string|null) {return inboxDto(await this.call('inbox'+(cursor?'?before='+encodeURIComponent(cursor):'')));}
  async markRead(id:string) {await this.call('read',{id});}
}
