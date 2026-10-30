import { BlockFailure } from '../../../../shared/features/user_blocks/domain/user_blocks.ts';
export class UserBlockSource {
  constructor(private readonly config:{url:string;key:string},private readonly token:string,private readonly fetcher:typeof fetch=fetch) {}
  async rpc(name:'list_user_blocks'|'prepare_user_block'|'set_user_block',params:unknown) {
    try {
      const response=await this.fetcher(this.config.url+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:this.config.key,Authorization:'Bearer '+this.token,'Content-Type':'application/json'},body:JSON.stringify(params),cache:'no-store',redirect:'error',signal:AbortSignal.timeout(15000)});
      if (!response.ok) {await response.body?.cancel();throw new BlockFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':response.status===409?'conflict':response.status===400?'invalid':'unavailable');}
      const reader=response.body?.getReader();if(!reader)throw new BlockFailure('unavailable');
      const chunks=[];let size=0;
      try {while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>65536)throw new BlockFailure('unavailable');chunks.push(value);}}
      finally{await reader.cancel().catch(()=>{});}
      return JSON.parse(Buffer.concat(chunks).toString('utf8'));
    }catch(e){throw e instanceof BlockFailure?e:new BlockFailure('unavailable');}
  }
}
