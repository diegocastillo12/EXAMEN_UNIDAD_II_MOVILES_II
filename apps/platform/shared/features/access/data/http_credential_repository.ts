import { CredentialFailure } from '../domain/credentials.ts';
import type { CredentialIssue, CredentialKind, CredentialRepository } from '../domain/credentials.ts';
import { credentialProgressDto, credentialResultDto } from './credential_dto.ts';
const issues: readonly CredentialIssue[] = ['invalid_request', 'invalid_name', 'invalid_email', 'weak_password', 'password_mismatch', 'invalid_code', 'expired', 'same_password', 'rate_limited', 'unavailable', 'conflict'];
export class HttpCredentialRepository implements CredentialRepository {
  constructor(private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init)) {}
  private async call(action: string, body?: unknown): Promise<Record<string, unknown>> {
    try {
      const response = await this.fetcher('/api/access/credentials' + (action ? '/' + action : ''), {
        method: body === undefined ? 'GET' : 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: body === undefined ? {} : { 'Content-Type': 'application/json' }, ...(body === undefined ? {} : { body: JSON.stringify(body) }), signal: AbortSignal.timeout(20000),
      });
      const raw = await response.json() as Record<string, unknown>;
      if (!response.ok) throw new CredentialFailure(response.status === 429 ? 'rate_limited' : issues.includes(raw?.error as CredentialIssue) ? raw.error as CredentialIssue : response.status === 401 ? 'expired' : 'unavailable');
      if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw new CredentialFailure('unavailable');
      return raw;
    } catch (error) { throw error instanceof CredentialFailure ? error : new CredentialFailure('unavailable'); }
  }
  async progress() { return credentialProgressDto((await this.call('')).progress); }
  async register(name: string, email: string, password: string) { return credentialResultDto(await this.call('register', { name, email, password, confirmation: password })); }
  async requestRecovery(email: string) { const progress = credentialProgressDto((await this.call('recover', { email })).progress); if (!progress || progress.kind !== 'recovery') throw new CredentialFailure('unavailable'); return progress; }
  async verify(kind: CredentialKind, id: string, code: string) { return credentialResultDto(await this.call('verify', { kind, id, code })); }
  async resend(kind: CredentialKind, id: string) { const progress = credentialProgressDto((await this.call('resend', { kind, id })).progress); if (!progress || progress.kind !== kind || progress.id !== id) throw new CredentialFailure('unavailable'); return progress; }
  async resetAccess() { if ((await this.call('reset-access')).allowed !== true) throw new CredentialFailure('expired'); }
  async reset(id: string, password: string) { if ((await this.call('reset', { id, password, confirmation: password })).updated !== true) throw new CredentialFailure('unavailable'); }
  async cancel() { if ((await this.call('cancel', {})).cancelled !== true) throw new CredentialFailure('unavailable'); }
}
