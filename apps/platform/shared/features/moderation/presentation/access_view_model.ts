import { ModerationFailure } from '../domain/moderation.ts';
import type { AccessModeration, ReviewerSession } from '../domain/moderation.ts';
export type AccessState = Readonly<{
  checking: boolean; busy: boolean; session: ReviewerSession | null;
  failure: ModerationFailure | null; notice: number;
}>;
const initial = (): AccessState => Object.freeze({ checking: true, busy: false, session: null, failure: null, notice: 0 });
export class AccessViewModel {
  state = initial();
  private generation = 0;
  private disposed = false;
  private listeners = new Set<(state: AccessState) => void>();
  constructor(private readonly access: AccessModeration) {}
  subscribe(listener: (state: AccessState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(patch: Partial<AccessState>) {
    if (this.disposed) return;
    this.state = Object.freeze({ ...this.state, ...patch });
    for (const listener of this.listeners) listener(this.state);
  }
  private fail(error: unknown, silent = false) {
    const failure = error instanceof ModerationFailure ? error : new ModerationFailure('unavailable');
    this.emit({ checking: false, busy: false, session: null, failure: silent && failure.kind === 'unauthenticated' ? null : failure, notice: this.state.notice + 1 });
  }
  async checkSession() {
    if (this.disposed || this.state.busy) return;
    const generation = ++this.generation;
    this.emit({ checking: true, session: null, failure: null });
    try { const session = await this.access.session(); if (generation === this.generation) this.emit({ checking: false, session, failure: null }); }
    catch (error) { if (generation === this.generation) this.fail(error, true); }
  }
  async login(email: string, password: string) {
    if (this.disposed || this.state.busy || this.state.checking) return;
    const generation = ++this.generation;
    this.emit({ busy: true, session: null, failure: null });
    try { const session = await this.access.login(email, password); if (generation === this.generation) this.emit({ busy: false, session, failure: null }); }
    catch (error) { if (generation === this.generation) this.fail(error); }
  }
  dispose() { ++this.generation; this.disposed = true; this.listeners.clear(); this.state = initial(); }
}
