import { CredentialFailure } from '../domain/credentials.ts';
import type { CredentialKind, CredentialProgress, CredentialResult, RegisterAccount, RequestPasswordRecovery, VerifyAccountCode, ResendAccountCode, ResetAccountPassword, ReadCredentialProgress, CancelCredentialFlow } from '../domain/credentials.ts';
import type { AccountSession } from '../domain/access.ts';
export type CredentialState = Readonly<{ checking: boolean; ready: boolean; busy: boolean; action: string | null; progress: CredentialProgress | null; session: AccountSession | null; failure: CredentialFailure | null; notice: number; seconds: number; completed: boolean; resent: boolean }>;
const initial = (): CredentialState => Object.freeze({ checking: true, ready: false, busy: false, action: null, progress: null, session: null, failure: null, notice: 0, seconds: 0, completed: false, resent: false });
export class CredentialViewModel {
  state = initial();
  private disposed = false;
  private generation = 0;
  private blockedUntil = 0;
  private listeners = new Set<(state: CredentialState) => void>();
  constructor(private readonly registration: RegisterAccount, private readonly recovery: RequestPasswordRecovery, private readonly verification: VerifyAccountCode, private readonly resending: ResendAccountCode, private readonly resetting: ResetAccountPassword, private readonly reading: ReadCredentialProgress, private readonly cancelling: CancelCredentialFlow, private readonly now = Date.now) {}
  subscribe(listener: (state: CredentialState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(patch: Partial<CredentialState>) { if (this.disposed) return; this.state = Object.freeze({ ...this.state, ...patch }); for (const listener of this.listeners) listener(this.state); }
  private fail(error: unknown) { const failure = error instanceof CredentialFailure ? error : new CredentialFailure('unavailable'); if (failure.kind === 'rate_limited') this.blockedUntil = this.now() + 60000; this.emit({ busy: false, checking: false, action: null, failure, notice: this.state.notice + 1, ...(failure.kind === 'rate_limited' ? { seconds: 60 } : {}) }); }
  tick() {
    const progress = this.state.progress;
    if (this.disposed || this.state.busy) return;
    if (progress && progress.expiresAt <= this.now() && this.state.failure?.kind !== 'expired') { this.fail(new CredentialFailure('expired')); return; }
    const seconds = Math.max(0, Math.ceil((Math.max(progress?.retryAt ?? 0, this.blockedUntil) - this.now()) / 1000));
    if (seconds !== this.state.seconds) this.emit({ seconds });
  }
  async initialize(kind: CredentialKind, resetPage = false) {
    if (this.disposed || this.state.busy) return;
    const generation = ++this.generation; this.emit({ checking: true, ready: false, failure: null });
    try {
      if (resetPage) await this.reading.resetAccess();
      const progress = await this.reading.execute();
      if (generation !== this.generation) return;
      if (resetPage && (!progress || progress.stage !== 'reset')) throw new CredentialFailure('expired');
      this.emit({ checking: false, ready: true, progress: progress?.kind === kind ? progress : null }); this.tick();
    } catch (error) { if (generation === this.generation) this.fail(error); }
  }
  async checkResetAccess() { await this.reading.resetAccess(); }
  private async run(action: string, operation: () => Promise<Partial<CredentialState>>) {
    if (this.disposed || this.state.checking || this.state.busy || !this.state.ready) return;
    if (action !== 'cancel' && this.blockedUntil > this.now()) return;
    const generation = ++this.generation; this.emit({ busy: true, action, failure: null, resent: false });
    try { const patch = await operation(); if (generation === this.generation) { this.emit({ busy: false, action: null, ...patch }); this.tick(); } }
    catch (error) { if (generation === this.generation) this.fail(error); }
  }
  private result(value: CredentialResult): Partial<CredentialState> { return { progress: value.progress, session: value.session }; }
  register(name: string, email: string, password: string, confirmation: string) { return this.run('register', async () => this.result(await this.registration.execute(name, email, password, confirmation))); }
  recover(email: string) { return this.run('recover', async () => ({ progress: await this.recovery.execute(email) })); }
  verify(code: string) { return this.run('verify', async () => { const p = this.state.progress; if (!p) throw new CredentialFailure('expired'); return this.result(await this.verification.execute(p.kind, p.id, code)); }); }
  resend() { if (this.state.seconds > 0) return Promise.resolve(); return this.run('resend', async () => { const p = this.state.progress; if (!p) throw new CredentialFailure('expired'); return { progress: await this.resending.execute(p), resent: true, notice: this.state.notice + 1 }; }); }
  reset(password: string, confirmation: string) { return this.run('reset', async () => { const p = this.state.progress; if (!p) throw new CredentialFailure('expired'); await this.resetting.execute(p.id, password, confirmation); return { completed: true, progress: null, notice: this.state.notice + 1 }; }); }
  cancel() { return this.run('cancel', async () => { await this.cancelling.execute(); return { progress: null, failure: null, seconds: 0, completed: false }; }); }
  edited() { if (!this.state.busy && this.state.failure && !['expired', 'conflict'].includes(this.state.failure.kind)) this.emit({ failure: null }); }
  dispose() { ++this.generation; this.disposed = true; this.listeners.clear(); this.state = initial(); }
}
