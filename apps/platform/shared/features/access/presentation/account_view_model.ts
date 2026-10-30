import { AccessFailure } from '../domain/access.ts';
import type { AccessAccount, AccountSession, CompleteAccountOnboarding, ReadManagementAccess, SocialProvider, StartAccountSocialSignIn } from '../domain/access.ts';
export type AccountState = Readonly<{
  checking: boolean; busy: boolean; socialProvider: SocialProvider | null; session: AccountSession | null;
  failure: AccessFailure | null; notice: number; step: number; canReview: boolean | null;
  checkingManagement: boolean; managementFailed: boolean;
}>;
const initial = (): AccountState => Object.freeze({ checking: true, busy: false, socialProvider: null, session: null, failure: null, notice: 0, step: 0, canReview: null, checkingManagement: false, managementFailed: false });
export class AccountViewModel {
  state = initial();
  private generation = 0;
  private managementGeneration = 0;
  private disposed = false;
  private listeners = new Set<(value: AccountState) => void>();
  constructor(private readonly access: AccessAccount, private readonly social: StartAccountSocialSignIn, private readonly onboarding: CompleteAccountOnboarding, private readonly management: ReadManagementAccess, prepared: AccountSession | null = null) {
    if (prepared && prepared.expiresAt > Date.now()) this.state = Object.freeze({ ...initial(), checking: false, session: prepared });
  }
  subscribe(listener: (value: AccountState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(patch: Partial<AccountState>) {
    if (this.disposed) return;
    this.state = Object.freeze({ ...this.state, ...patch });
    for (const listener of this.listeners) listener(this.state);
  }
  private fail(error: unknown, preserve = false, silent = false) {
    const failure = error instanceof AccessFailure ? error : new AccessFailure('unavailable');
    const keep = preserve && failure.kind !== 'unauthenticated' && failure.kind !== 'conflict';
    this.emit({ checking: false, busy: false, checkingManagement: false, socialProvider: null,
      ...(!keep ? { session: null, canReview: null, step: 0 } : {}), failure: silent && failure.kind === 'unauthenticated' ? null : failure, notice: this.state.notice + 1 });
  }
  async checkSession() {
    if (this.disposed || this.state.busy) return;
    const generation = ++this.generation;
    ++this.managementGeneration;
    this.emit({ checking: true, session: null, canReview: null, failure: null, managementFailed: false, checkingManagement: false, step: 0 });
    try { const session = await this.access.session(); if (generation === this.generation) this.emit({ checking: false, session }); }
    catch (error) { if (generation === this.generation) this.fail(error, false, true); }
  }
  async login(email: string, password: string) {
    if (this.disposed || this.state.busy || this.state.checking) return;
    const generation = ++this.generation;
    this.emit({ busy: true, session: null, canReview: null, failure: null });
    try { const session = await this.access.login(email, password); if (generation === this.generation) this.emit({ busy: false, session }); }
    catch (error) { if (generation === this.generation) this.fail(error); }
  }
  async signInWithProvider(provider: SocialProvider): Promise<string | null> {
    if (this.disposed || this.state.busy || this.state.checking) return null;
    const generation = ++this.generation;
    this.emit({ busy: true, socialProvider: provider, failure: null });
    try {
      const url = await this.social.execute(provider);
      // Keep the action locked while the browser navigates to the provider.
      return !this.disposed && generation === this.generation ? url : null;
    } catch (error) { if (generation === this.generation) this.fail(error); return null; }
  }
  previousStep() { if (!this.state.busy && this.state.step > 0) this.emit({ step: this.state.step - 1 }); }
  async nextStep() {
    if (!this.state.session || this.state.busy || this.disposed) return;
    if (this.state.step < 2) { this.emit({ step: this.state.step + 1 }); return; }
    const generation = this.generation, actor = this.state.session.actor;
    this.emit({ busy: true, failure: null });
    try {
      const session = await this.onboarding.execute();
      if (generation !== this.generation || this.disposed) return;
      if (session.actor !== actor) throw new AccessFailure('conflict');
      if (!session.profile.onboardingCompleted) throw new AccessFailure('unavailable');
      this.emit({ busy: false, session });
    } catch (error) { if (generation === this.generation) this.fail(error, true); }
  }
  async loadManagementAccess() {
    if (!this.state.session || this.state.checkingManagement || this.disposed) return;
    const generation = this.generation, request = ++this.managementGeneration;
    this.emit({ checkingManagement: true, canReview: null, failure: null });
    try { const canReview = await this.management.execute(); if (generation === this.generation && request === this.managementGeneration) this.emit({ canReview, checkingManagement: false, managementFailed: false }); }
    catch (error) { if (generation === this.generation && request === this.managementGeneration) { this.emit({ managementFailed: true }); this.fail(error, true); } }
  }
  async logout() {
    if (this.state.busy || this.disposed) return false;
    const generation = ++this.generation; ++this.managementGeneration;
    this.emit({ ...initial(), checking: false, busy: true });
    try {
      await this.access.logout();
      if (this.disposed || generation !== this.generation) return false;
      this.emit({ busy: false }); return true;
    }
    catch (error) { if (generation === this.generation) this.fail(error); return false; }
  }
  invalidate() { ++this.generation; ++this.managementGeneration; this.emit({ ...initial(), notice: this.state.notice }); }
  dispose() { ++this.generation; ++this.managementGeneration; this.disposed = true; this.listeners.clear(); this.state = initial(); }
}

