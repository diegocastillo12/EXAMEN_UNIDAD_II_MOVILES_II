import { CredentialFailure } from '../../../../shared/features/access/domain/credentials.ts';
import type { CredentialKind, CredentialRepository, CredentialResult } from '../../../../shared/features/access/domain/credentials.ts';
import { newCredentialFlow, publicCredentialFlow } from '../../../infrastructure/credential_flow.ts';
import type { PrivateCredentialFlow } from '../../../infrastructure/credential_flow.ts';
import type { PrivateAccountSession } from '../../../infrastructure/account_session.ts';
import { AccountSource } from './account_source.ts';
import { ServerAccountRepository } from './server_account_repository.ts';
import { CredentialSource } from './credential_source.ts';

export class ServerCredentialRepository implements CredentialRepository {
  established: PrivateAccountSession | null = null;
  constructor(private readonly source: CredentialSource, private readonly accounts: AccountSource, public flow: PrivateCredentialFlow | null) {}
  async progress() { return this.flow ? publicCredentialFlow(this.flow) : null; }
  private require(kind: CredentialKind, id: string) {
    const flow = this.flow;
    if (!flow || flow.expiresAt <= Date.now()) throw new CredentialFailure('expired');
    if (flow.kind !== kind || flow.id !== id) throw new CredentialFailure('conflict');
    return flow;
  }
  private token(value: unknown): PrivateAccountSession {
    const raw = value as { access_token?: unknown; expires_in?: unknown; user?: { id?: unknown } } | null;
    if (!raw || typeof raw.access_token !== 'string' || !raw.access_token || raw.access_token.length > 2400 || typeof raw.user?.id !== 'string' || !/^[0-9a-f-]{36}$/.test(raw.user.id) || typeof raw.expires_in !== 'number' || !Number.isFinite(raw.expires_in) || raw.expires_in < 1) throw new CredentialFailure('unavailable');
    return { actor: raw.user.id, token: raw.access_token, expiresAt: Date.now() + Math.min(raw.expires_in, 3600) * 1000 };
  }
  private async signIn(raw: unknown, email: string): Promise<CredentialResult> {
    const established = this.token(raw), repository = new ServerAccountRepository(this.accounts, established);
    try { const session = await repository.session(); if (session.email?.toLowerCase() !== email.toLowerCase()) throw new CredentialFailure('expired'); this.established = established; this.flow = null; return { session, progress: null }; }
    catch { await this.accounts.logout(established.token); throw new CredentialFailure('unavailable'); }
  }
  async register(name: string, email: string, password: string): Promise<CredentialResult> {
    const raw = await this.source.register(name, email, password) as { access_token?: unknown; id?: unknown; user?: unknown } | null;
    if (!raw || (typeof raw.id !== 'string' && !raw.user)) throw new CredentialFailure('unavailable');
    if (raw.access_token) return this.signIn(raw, email);
    // Identical pending response for existing addresses and unconfirmed new users.
    this.flow = newCredentialFlow('registration', email);
    return { session: null, progress: publicCredentialFlow(this.flow) };
  }
  async requestRecovery(email: string) {
    await this.source.recover(email); this.flow = newCredentialFlow('recovery', email);
    return publicCredentialFlow(this.flow);
  }
  async verify(kind: CredentialKind, id: string, code: string): Promise<CredentialResult> {
    const flow = this.require(kind, id);
    if (flow.recovery) throw new CredentialFailure('conflict');
    const raw = await this.source.verify(flow.email, code, kind === 'recovery');
    if (kind === 'registration') return this.signIn(raw, flow.email);
    const session = this.token(raw), user = await this.source.user(session.token) as { id?: unknown; email?: unknown } | null;
    if (user?.id !== session.actor || typeof user.email !== 'string' || user.email.toLowerCase() !== flow.email.toLowerCase()) throw new CredentialFailure('expired');
    this.flow = { ...flow, recovery: session, expiresAt: Math.min(session.expiresAt, Date.now() + 600000) };
    return { session: null, progress: publicCredentialFlow(this.flow) };
  }
  async resend(kind: CredentialKind, id: string) {
    const flow = this.require(kind, id);
    if (flow.recovery) throw new CredentialFailure('conflict');
    if (flow.retryAt > Date.now()) throw new CredentialFailure('rate_limited');
    if (kind === 'registration') await this.source.resend(flow.email); else await this.source.recover(flow.email);
    this.flow = { ...flow, retryAt: Date.now() + 60000 };
    return publicCredentialFlow(this.flow);
  }
  async resetAccess() {
    const flow = this.flow;
    if (!flow?.recovery || flow.kind !== 'recovery' || flow.expiresAt <= Date.now() || flow.recovery.expiresAt <= Date.now()) throw new CredentialFailure('expired');
    const user = await this.source.user(flow.recovery.token) as { id?: unknown } | null;
    if (user?.id !== flow.recovery.actor) throw new CredentialFailure('expired');
  }
  async reset(id: string, password: string) {
    const flow = this.require('recovery', id); await this.resetAccess();
    const updated = await this.source.update(flow.recovery!.token, password) as { id?: unknown } | null;
    if (updated?.id !== flow.recovery!.actor) throw new CredentialFailure('unavailable');
    const token = flow.recovery!.token; this.flow = null;
    await this.accounts.logout(token);
  }
  async cancel() { const token = this.flow?.recovery?.token; this.flow = null; if (token) await this.accounts.logout(token); }
}
