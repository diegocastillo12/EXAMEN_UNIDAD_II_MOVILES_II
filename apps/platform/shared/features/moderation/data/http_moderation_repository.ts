import { ModerationFailure } from '../domain/moderation.ts';
import type { ModerationRepository, ModerationCommand, QueueCursor, ReviewerSession, ReportPage, ReportDetail, DecisionReceipt } from '../domain/moderation.ts';
// The same-origin API exposes typed entities, never database credentials or tokens.
export class HttpModerationRepository implements ModerationRepository {
  private actor = '';
  constructor(private readonly fetcher: typeof fetch = (input,init)=>globalThis.fetch(input,init)) {}
  private async call(path: string, body?: unknown, bindActor = true): Promise<unknown> {
    try {
      const response = await this.fetcher(`/api/moderation/${path}`, { method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { ...(body === undefined ? {} : { 'Content-Type': 'application/json' }), ...(bindActor ? { 'X-Moderation-Actor': this.actor } : {}) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), signal: AbortSignal.timeout(20000) });
      if (!response.ok) {
        const issue = response.status === 401 ? 'unauthenticated' : response.status === 403 ? 'forbidden' : response.status === 409 ? 'conflict' : response.status === 422 ? 'invalid' : 'unavailable';
        await response.body?.cancel(); throw new ModerationFailure(issue);
      }
      return await response.json();
    } catch (error) { throw error instanceof ModerationFailure ? error : new ModerationFailure('unavailable'); }
  }
  async session(): Promise<ReviewerSession> { const s = await this.call('session', undefined, false) as ReviewerSession; this.actor = s.actor; return s; }
  async login(email: string, password: string): Promise<ReviewerSession> { const s = await this.call('login', {email,password}, false) as ReviewerSession; this.actor = s.actor; return s; }
  async logout(): Promise<void> { await this.call('logout', {}, false); this.actor = ''; }
  async list(resolved: boolean, cursor: QueueCursor | null): Promise<ReportPage> { return await this.call('queue', {resolved,cursor}) as ReportPage; }
  async read(id: string): Promise<ReportDetail> { return await this.call(`reports/${id}`) as ReportDetail; }
  async decide(command: ModerationCommand): Promise<DecisionReceipt> { return await this.call('decisions', command) as DecisionReceipt; }
}
