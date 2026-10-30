import { ModerationFailure } from '../../../../shared/features/moderation/domain/moderation.ts';
export type ModerationConfig = { url: string; key: string; sessionSecret: string; secure: boolean };
export async function boundedJson(response: Response, limit = 65536): Promise<unknown> {
  const reader=response.body?.getReader(); if(!reader) throw new ModerationFailure('unavailable');
  let count=0; const chunks: Uint8Array[]=[];
  try { while(true) { const {done,value}=await reader.read(); if(done)break; count+=value.length; if(count>limit)throw new ModerationFailure('unavailable'); chunks.push(value); } }
  finally { await reader.cancel().catch(()=>{}); }
  try { return JSON.parse(Buffer.concat(chunks).toString('utf8')); } catch { throw new ModerationFailure('unavailable'); }
}
export class ModerationSource {
  constructor(readonly config: ModerationConfig, private readonly fetcher: typeof fetch = fetch) {}
  private async request(path: string, token?: string, body?: unknown, limit=65536) {
    try {
      const response=await this.fetcher(`${this.config.url}${path}`,{method:body===undefined?'GET':'POST',
        headers:{apikey:this.config.key,...(token?{Authorization:`Bearer ${token}`} : {}),...(body===undefined?{}:{'Content-Type':'application/json'})},
        ...(body===undefined?{}:{body:JSON.stringify(body)}),redirect:'error',cache:'no-store',signal:AbortSignal.timeout(12000)});
      const value=await boundedJson(response,limit);
      if(!response.ok) {
        const message=(value as {message?:string})?.message;
        throw new ModerationFailure(response.status===401 || (path.startsWith('/auth/v1/token') && response.status===400)?'unauthenticated':message==='moderation_conflict'?'conflict':message==='moderation_invalid'?'invalid':response.status===403 || (value as {code?:string})?.code==='42501'?'forbidden':'unavailable');
      }
      return value;
    } catch(error) { throw error instanceof ModerationFailure?error:new ModerationFailure('unavailable'); }
  }
  async password(email: string,password: string) {
    try { return await this.request('/auth/v1/token?grant_type=password',undefined,{email,password}); }
    catch(error) { if(error instanceof ModerationFailure && ['invalid','unauthenticated'].includes(error.kind))throw new ModerationFailure('unauthenticated'); throw error; }
  }
  exchange(code: string, verifier: string) { return this.request('/auth/v1/token?grant_type=pkce',undefined,{auth_code:code,code_verifier:verifier}); }
  user(token: string) { return this.request('/auth/v1/user',token); }
  async logout(token: string) {
    // Local browser session only; never log the user's Android sessions out.
    try { await this.fetcher(`${this.config.url}/auth/v1/logout?scope=local`, {method:'POST',headers:{apikey:this.config.key,Authorization:`Bearer ${token}`},redirect:'error',cache:'no-store',signal:AbortSignal.timeout(5000)}); } catch { /* The browser cookie is still removed. */ }
  }
  rpc(token: string,name: string,params: Record<string,unknown>={},limit=65536) { return this.request(`/rest/v1/rpc/${name}`,token,params,limit); }
}
