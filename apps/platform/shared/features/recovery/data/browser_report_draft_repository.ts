import { RecoveryFailure } from '../domain/recovery.ts';
import type { ReportDraftRepository, LocalReportDraft } from '../domain/recovery.ts';
export class BrowserReportDraftRepository implements ReportDraftRepository {
  constructor(private readonly actor:string) {}
  private async transaction(write:boolean, value?:LocalReportDraft, remove = false):Promise<LocalReportDraft|null> {
    try {
      const db = await new Promise<IDBDatabase>((resolve,reject) => { const request = indexedDB.open('eh-report-drafts',1); request.onupgradeneeded = () => request.result.createObjectStore('drafts'); request.onsuccess = () => resolve(request.result); request.onerror = () => reject(request.error); });
      try { return await new Promise((resolve,reject) => {
        const tx = db.transaction('drafts',write ? 'readwrite' : 'readonly'), store = tx.objectStore('drafts');
        const request = write ? remove ? store.delete(this.actor) : store.put({ value,expires:Date.now()+7*86400000 },this.actor) : store.get(this.actor);
        let result:LocalReportDraft|null = null;
        request.onsuccess = () => { if (!write && request.result?.expires > Date.now()) result = request.result.value; };
        tx.oncomplete = () => resolve(result); tx.onerror = () => reject(tx.error); tx.onabort = () => reject(tx.error);
      }); } finally { db.close(); }
    } catch { throw new RecoveryFailure('unavailable'); }
  }
  read() { return this.transaction(false); }
  async save(value:LocalReportDraft) { await this.transaction(true,value); }
  async clear() { await this.transaction(true,undefined,true); }
}
