import { AccessFailure } from '../domain/access.ts';
import type { AccountRepository, SocialProvider, SocialSignInRepository } from '../domain/access.ts';
import { accountSessionDto } from './account_session_dto.ts';
export class HttpAccountRepository implements AccountRepository, SocialSignInRepository {
  constructor(private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init), private actor = '') {}
  private async call(path: string, body?: unknown, bind = false): Promise<unknown> {
    try {
      const response = await this.fetcher('/api/access/' + path, {
        method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { ...(body === undefined ? {} : { 'Content-Type': 'application/json' }), ...(bind ? { 'X-Account-Actor': this.actor } : {}) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), signal: AbortSignal.timeout(20000),
      });
      if (!response.ok) {
        const kind = response.status === 401 ? 'unauthenticated' : response.status === 403 ? 'forbidden' : response.status === 409 ? 'conflict' : response.status === 422 ? 'invalid' : 'unavailable';
        await response.body?.cancel(); throw new AccessFailure(kind);
      }
      return await response.json();
    } catch (error) { throw error instanceof AccessFailure ? error : new AccessFailure('unavailable'); }
  }
  async session() { const s = accountSessionDto(await this.call('session')); this.actor = s.actor; return s; }
  async login(email: string, password: string) { const s = accountSessionDto(await this.call('login', { email, password })); this.actor = s.actor; return s; }
  async logout() { await this.call('logout', {}); this.actor = ''; }
  async completeOnboarding() { return accountSessionDto(await this.call('onboarding', {}, true)); }
  async canReviewReports() {
    const data = await this.call('management', undefined, true) as { canReviewReports?: unknown };
    if (typeof data?.canReviewReports !== 'boolean') throw new AccessFailure('unavailable');
    return data.canReviewReports;
  }
  async start(provider: SocialProvider) {
    const value = await this.call('oauth/start', { provider }) as { url?: unknown };
    try {
      if (typeof value?.url !== 'string') throw Error();
      const url = new URL(value.url);
      if ((url.protocol !== 'https:' && !(url.protocol === 'http:' && ['127.0.0.1', 'localhost'].includes(url.hostname))) || url.username || url.password || url.pathname !== '/auth/v1/authorize' || url.searchParams.get('provider') !== provider) throw Error();
      return url.href;
    } catch { throw new AccessFailure('unavailable'); }
  }
}

