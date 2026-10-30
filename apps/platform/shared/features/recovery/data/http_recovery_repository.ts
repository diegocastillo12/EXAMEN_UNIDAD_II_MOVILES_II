import { RecoveryFailure } from '../domain/recovery.ts';
import type { RecoveryRepository, ExploreQuery, CasePage, Pet, PetDraft, ReportPhoto, ReportDraft, ReportReceipt, CaseCard } from '../domain/recovery.ts';
export class HttpRecoveryRepository implements RecoveryRepository {
  constructor(private readonly actor: string, private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init)) {}
  async publication(source:'lost'|'found',id:string){return await this.call('case',{source,id}) as import('../domain/recovery.ts').CasePublication;}
  private async call(path: string, body?: unknown, multipart = false): Promise<unknown> {
    try {
      const response = await this.fetcher('/api/recovery/' + path, { method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store', headers: { 'X-Account-Actor': this.actor, ...(!multipart && body !== undefined ? { 'Content-Type': 'application/json' } : {}) }, ...(body === undefined ? {} : { body: multipart ? body as FormData : JSON.stringify(body) }), signal: AbortSignal.timeout(multipart ? 120000 : 30000) });
      if (!response.ok) { await response.body?.cancel(); throw new RecoveryFailure(response.status === 423 ? 'blocked' : response.status === 401 ? 'unauthenticated' : response.status === 403 ? 'forbidden' : response.status === 409 ? 'conflict' : response.status === 422 ? 'invalid' : 'unavailable'); }
      return await response.json();
    } catch (e) { throw e instanceof RecoveryFailure ? e : new RecoveryFailure('unavailable'); }
  }
  async explore(query: ExploreQuery, cursor: string | null) { return await this.call('explore', { query, cursor }) as CasePage; }
  async pets() { return await this.call('pets') as readonly Pet[]; }
  async savePet(draft: PetDraft) { return await this.call('pets', draft) as Pet; }
  async uploadPetPhoto(pet: string, photo: ReportPhoto) {
    const body = new FormData(); body.set('draft', JSON.stringify({ pet, id: photo.id })); body.append('photo', new Blob([new Uint8Array(photo.bytes)], { type: 'application/octet-stream' }), photo.id);
    await this.call('pet-photo', body, true);
  }
  async targets() { return await this.call('targets') as readonly CaseCard[]; }
  async publish(draft: ReportDraft, photos: readonly ReportPhoto[]) {
    const body = new FormData(); body.set('draft', JSON.stringify(draft));
    for (const photo of photos) body.append('photo', new Blob([new Uint8Array(photo.bytes)], { type: 'application/octet-stream' }), photo.id);
    return await this.call('reports', body, true) as ReportReceipt;
  }
}
