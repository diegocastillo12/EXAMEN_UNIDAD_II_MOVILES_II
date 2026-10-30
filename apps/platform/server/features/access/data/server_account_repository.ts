import { AccessFailure } from '../../../../shared/features/access/domain/access.ts';
import type { AccountRepository, AccountSession } from '../../../../shared/features/access/domain/access.ts';
import { accountSessionDto } from '../../../../shared/features/access/data/account_session_dto.ts';
import type { PrivateAccountSession } from '../../../infrastructure/account_session.ts';
import { AccountSource } from './account_source.ts';
export class ServerAccountRepository implements AccountRepository {
  constructor(private readonly source: AccountSource, public established: PrivateAccountSession | null) {}
  private async identity() {
    const s = this.established;
    if (!s || s.expiresAt <= Date.now()) throw new AccessFailure('unauthenticated');
    const user = await this.source.user(s.token) as { id?: unknown; email?: unknown; is_anonymous?: unknown } | null;
    if (!user || user.id !== s.actor || user.is_anonymous === true) throw new AccessFailure('unauthenticated');
    return { session: s, email: typeof user.email === 'string' ? user.email : null };
  }
  async session(): Promise<AccountSession> {
    const current = this.established;
    if (!current || current.expiresAt <= Date.now()) throw new AccessFailure('unauthenticated');
    // Both reads use the same private token. Never return the profile until
    // identity validation has succeeded; RLS still applies to the profile read.
    const [{ session: s, email }, raw] = await Promise.all([this.identity(), this.source.profile(current.token, current.actor)]);
    const rows = raw as { id?: unknown; display_name?: unknown; city?: unknown; onboarding_completed_at?: unknown }[];
    const row = Array.isArray(rows) && rows.length === 1 ? rows[0] : undefined;
    if (!row || row.id !== s.actor || !(row.onboarding_completed_at === null || (typeof row.onboarding_completed_at === 'string' && Number.isFinite(Date.parse(row.onboarding_completed_at))))) throw new AccessFailure('unavailable');
    return accountSessionDto({ actor: s.actor, expiresAt: s.expiresAt, email, profile: {
      displayName: row.display_name, city: row.city, onboardingCompleted: row.onboarding_completed_at !== null,
    } });
  }
  private async establish(value: unknown) {
    const raw = value as { access_token?: unknown; expires_in?: unknown; user?: { id?: unknown } } | null;
    if (!raw || typeof raw.access_token !== 'string' || !raw.access_token || raw.access_token.length > 4096 ||
        typeof raw.user?.id !== 'string' || !/^[0-9a-f-]{36}$/.test(raw.user.id) ||
        typeof raw.expires_in !== 'number' || !Number.isFinite(raw.expires_in) || raw.expires_in < 1) throw new AccessFailure('unavailable');
    this.established = { actor: raw.user.id, token: raw.access_token, expiresAt: Date.now() + Math.min(3600, raw.expires_in) * 1000 };
    try { return await this.session(); }
    catch (error) { await this.source.logout(this.established.token); this.established = null; throw error; }
  }
  login(email: string, password: string) { return this.source.password(email, password).then(value => this.establish(value)); }
  exchange(code: string, verifier: string) {
    if (!code || code.length > 2048 || !/^[A-Za-z0-9_-]{43,128}$/.test(verifier)) throw new AccessFailure('unauthenticated');
    return this.source.exchange(code, verifier).then(value => this.establish(value));
  }
  async logout() { const s = this.established; this.established = null; if (s) await this.source.logout(s.token); }
  async avatar() { const {session}=await this.identity();return this.source.avatar(session.token,session.actor); }
  async completeOnboarding() {
    const { session } = await this.identity();
    await this.source.completeOnboarding(session.token);
    return this.session();
  }
  async canReviewReports() {
    const { session } = await this.identity();
    try { return await this.source.reviewer(session.token) === session.actor; }
    catch (error) { if (error instanceof AccessFailure && error.kind === 'forbidden') return false; throw error; }
  }
}

