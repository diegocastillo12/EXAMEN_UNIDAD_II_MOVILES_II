import { InboxFailure } from '../../../../shared/features/notifications/domain/inbox.ts';
export class InboxSource {
  constructor(private readonly config:{url:string;key:string},private readonly token:string,private readonly fetcher:typeof fetch=fetch) {}
  async rpc(name:'list_notifications'|'mark_notification_read',params:unknown) {
    try {
      const response=await this.fetcher(this.config.url+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:this.config.key,Authorization:'Bearer '+this.token,'Content-Type':'application/json'},body:JSON.stringify(params),cache:'no-store',redirect:'error',signal:AbortSignal.timeout(15000)});
      if (!response.ok) {await response.body?.cancel();throw new InboxFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':response.status===409?'conflict':'unavailable');}
      if (response.status===204) return null;
      const reader=response.body?.getReader();if (!reader) return null;
      const chunks=[];let size=0;
      try {while (true) {const {done,value}=await reader.read();if (done) break;size+=value.length;if (size>65536) throw new InboxFailure('unavailable');chunks.push(value);}}
      finally {await reader.cancel().catch(()=>{});}
      const bytes=Buffer.concat(chunks);return bytes.length?JSON.parse(bytes.toString('utf8')):null;
    } catch(e) {throw e instanceof InboxFailure?e:new InboxFailure('unavailable');}
  }
}
