import { AccessFailure } from '../../../../shared/features/access/domain/access.ts';
export type AccountConfig = { url: string; key: string; sessionSecret: string; secure: boolean };
export class AccountSource {
  constructor(readonly config: AccountConfig, private readonly fetcher: typeof fetch = fetch) {}
  private async request(path: string, token?: string, body?: unknown, allowNoContent = false): Promise<unknown> {
    try {
      const response = await this.fetcher(this.config.url + path, {
        method: body === undefined ? 'GET' : 'POST',
        headers: { apikey: this.config.key, ...(token ? { Authorization: 'Bearer ' + token } : {}), ...(body === undefined ? {} : { 'Content-Type': 'application/json' }) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(12000),
      });
      if (!response.ok) {
        await response.body?.cancel();
        throw new AccessFailure(response.status === 401 || (path.startsWith('/auth/v1/token') && response.status === 400) ? 'unauthenticated' : response.status === 403 ? 'forbidden' : 'unavailable');
      }
      // complete_onboarding returns void; PostgREST can acknowledge it without a body.
      if (allowNoContent && response.status === 204) return null;
      const reader = response.body?.getReader();
      if (!reader) throw new AccessFailure('unavailable');
      const chunks: Uint8Array[] = []; let count = 0;
      try { while (true) { const { done, value } = await reader.read(); if (done) break; count += value.length; if (count > 65536) throw new AccessFailure('unavailable'); chunks.push(value); } }
      finally { await reader.cancel().catch(() => {}); }
      const raw = Buffer.concat(chunks).toString('utf8');
      return raw ? JSON.parse(raw) : null;
    } catch (error) { throw error instanceof AccessFailure ? error : new AccessFailure('unavailable'); }
  }
  password(email: string, password: string) { return this.request('/auth/v1/token?grant_type=password', undefined, { email, password }); }
  exchange(code: string, verifier: string) { return this.request('/auth/v1/token?grant_type=pkce', undefined, { auth_code: code, code_verifier: verifier }); }
  user(token: string) { return this.request('/auth/v1/user', token); }
  profile(token: string, actor: string) {
    return this.request('/rest/v1/profiles?select=id,display_name,city,onboarding_completed_at&id=eq.' + encodeURIComponent(actor), token);
  }
  completeOnboarding(token: string) { return this.request('/rest/v1/rpc/complete_onboarding', token, {}, true); }
  reviewer(token: string) { return this.request('/rest/v1/rpc/require_content_reviewer', token, {}); }
  async avatar(token:string,actor:string):Promise<Uint8Array|null> {
    try {
      const response=await this.fetcher(this.config.url+'/storage/v1/object/authenticated/profile-avatars/'+encodeURIComponent(actor)+'/avatar.jpg',{
        headers:{apikey:this.config.key,Authorization:'Bearer '+token},cache:'no-store',redirect:'error',signal:AbortSignal.timeout(12000),
      });
      if (!response.ok) { await response.body?.cancel();if ([400,404].includes(response.status)) return null;throw new AccessFailure(response.status===401?'unauthenticated':response.status===403?'forbidden':'unavailable'); }
      const reader=response.body?.getReader();if (!reader) return null;
      const chunks:Uint8Array[]=[];let size=0;
      try { while (true) { const {done,value}=await reader.read();if (done) break;size+=value.length;if (size>2097152) throw new AccessFailure('unavailable');chunks.push(value); } }
      finally { await reader.cancel().catch(()=>{}); }
      const bytes=Buffer.concat(chunks);
      if (bytes.length<3 || bytes[0]!==255 || bytes[1]!==216 || bytes[2]!==255) throw new AccessFailure('unavailable');
      return bytes;
    } catch(e) { throw e instanceof AccessFailure?e:new AccessFailure('unavailable'); }
  }
  async logout(token: string) {
    try {
      await this.fetcher(this.config.url + '/auth/v1/logout?scope=local', { method: 'POST', headers: { apikey: this.config.key, Authorization: 'Bearer ' + token }, redirect: 'error', cache: 'no-store', signal: AbortSignal.timeout(5000) });
    } catch { /* Browser cookie removal remains effective; access JWT keeps its original expiry. */ }
  }
}

