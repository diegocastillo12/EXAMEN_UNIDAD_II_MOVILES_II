import { RecoveryFailure } from '../../../../shared/features/recovery/domain/recovery.ts';
type RecoveryConfig = Readonly<{ url:string;key:string }>;
export class RecoverySource {
  constructor(private readonly config: RecoveryConfig, private readonly token: string, private readonly fetcher: typeof fetch = fetch) {}
  async request(path: string, body?: unknown, headers: Record<string,string> = {}, binary = false): Promise<unknown> {
    try {
      const response = await this.fetcher(this.config.url + path, { method: body === undefined ? 'GET' : 'POST', headers: { apikey: this.config.key, Authorization: 'Bearer ' + this.token, ...(body !== undefined ? { 'Content-Type': binary ? 'image/jpeg' : 'application/json' } : {}), ...headers }, ...(body === undefined ? {} : { body: binary ? new Uint8Array(body as Uint8Array) : JSON.stringify(body) }), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(binary ? 60000 : 15000) });
      if (!response.ok) {
        let code = '',blocked=false; try { const value=await response.json();code=value?.code || '';blocked=value?.message==='interaction_blocked'; } catch { /* No upstream messages cross the boundary. */ }
        throw new RecoveryFailure(blocked?'blocked':response.status === 401 ? 'unauthenticated' : response.status === 403 || code === '42501' ? 'forbidden' : response.status === 409 || ['40001','23505'].includes(code) ? 'conflict' : ['23514','22023'].includes(code) || response.status === 422 ? 'invalid' : 'unavailable');
      }
      const reader = response.body?.getReader(); if (!reader) return null;
      const chunks = []; let size = 0;
      try { while (true) { const { done, value } = await reader.read(); if (done) break; size += value.length; if (size > 4194304) throw new RecoveryFailure('unavailable'); chunks.push(value); } }
      finally { await reader.cancel().catch(() => {}); }
      const bytes = Buffer.concat(chunks);
      return path.startsWith('/storage/') ? bytes : bytes.length ? JSON.parse(bytes.toString('utf8')) : null;
    } catch (e) { throw e instanceof RecoveryFailure ? e : new RecoveryFailure('unavailable'); }
  }
  rpc(name: string, params: unknown = {}) { return this.request('/rest/v1/rpc/' + name, params); }
  petRows(actor: string) { return this.request('/rest/v1/pets?select=id,owner_id,name,species,species_detail,size,sex,age_months,traits,version,archived_at,pet_photos(id,status,processed_at,created_at,is_primary)&owner_id=eq.' + encodeURIComponent(actor) + '&archived_at=is.null&order=created_at.desc,id.asc&limit=100'); }
  processPhoto(parent: string, id: string, bytes: Uint8Array, found = false) { return this.request('/functions/v1/pet-photo-process', bytes, { [found ? 'x-found-case-id' : 'x-pet-id']: parent, 'x-photo-id': id }, true); }
  photo(bucket: string, path: string) { return this.request('/storage/v1/object/authenticated/' + bucket + '/' + path.split('/').map(encodeURIComponent).join('/')); }
}
