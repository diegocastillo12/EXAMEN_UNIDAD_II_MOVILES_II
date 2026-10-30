import { AppealFailure } from '../domain/appeals.ts';
import type { AppealEntry, AppealCommand, AppealCursor, AppealIssue, ReadAppeals, SubmitAppeal, AnswerAppeal } from '../domain/appeals.ts';
export type AppealsState = Readonly<{
  items: readonly AppealEntry[]; next: AppealCursor | null; selected: AppealEntry | null; reason: string;
  ready: boolean; busy: boolean; failure: AppealIssue | null; notice: number; saved: boolean; frozen: AppealCommand | null; refreshRequired: boolean; retrying: boolean;
}>;
export class AppealsViewModel {
  state: AppealsState = Object.freeze({ items: [], next: null, selected: null, reason: '', ready: false, busy: false, failure: null, notice: 0, saved: false, frozen: null, refreshRequired: false, retrying: false });
  private listeners = new Set<(s: AppealsState) => void>();
  private disposed = false;
  private generation = 0;
  constructor(private readonly read: ReadAppeals, private readonly submit: SubmitAppeal, private readonly answer: AnswerAppeal, readonly review: boolean, private readonly createId: () => string) {}
  subscribe(listener: (s: AppealsState) => void) { this.listeners.add(listener); return () => { this.listeners.delete(listener); }; }
  private patch(values: Partial<AppealsState>) { if (this.disposed) return; this.state = Object.freeze({ ...this.state, ...values }); for (const listener of this.listeners) listener(this.state); }
  private fail(error: unknown) {
    const failure = error instanceof AppealFailure ? error.kind : 'unavailable';
    this.patch({ failure, notice: this.state.notice + 1, retrying: !!this.state.frozen,
      ...(failure === 'invalid' ? { frozen: null, retrying: false } : {}),
      ...(failure === 'conflict' ? { refreshRequired: true } : {}),
      ...(['forbidden','unauthenticated'].includes(failure) ? { items: [], selected: null, reason: '', frozen: null, next: null, ready: false } : {}) });
  }
  async load(more = false) {
    if (this.disposed || this.state.busy || (more && !this.state.next) || (this.state.frozen && !this.state.refreshRequired)) return;
    const generation = ++this.generation, cursor = more ? this.state.next : null;
    this.patch({ busy: true, failure: null, saved: false });
    try {
      const page = await this.read.execute(this.review, cursor); if (this.disposed || generation !== this.generation) return;
      const items = more ? [...this.state.items, ...page.items.filter(item => !this.state.items.some(old => old.decision === item.decision))] : page.items;
      this.patch({ items, next: page.next, ready: true, frozen: null, refreshRequired: false, retrying: false,
        selected: this.state.selected ? items.find(item => item.decision === this.state.selected?.decision) ?? null : null });
    } catch (error) { if (generation === this.generation) this.fail(error); }
    finally { if (generation === this.generation) this.patch({ busy: false }); }
  }
  select(item: AppealEntry | null) { if (!this.state.busy && !this.state.frozen) this.patch({ selected: item, reason: '', saved: false, failure: null, retrying: false }); }
  edit(reason: string) { if (!this.state.busy && !this.state.frozen) this.patch({ reason, failure: null, saved: false }); }
  async send() {
    const s = this.state;
    if (this.disposed || s.busy || !s.selected || s.refreshRequired || s.selected.appeal?.answer || (!this.review && s.selected.appeal) || (this.review && !s.selected.appeal)) return;
    if (!s.frozen && (!s.reason.trim() || [...s.reason.trim()].length > 1000)) { this.fail(new AppealFailure('invalid')); return; }
    const command = s.frozen ?? Object.freeze({ id: this.createId(), target: this.review ? s.selected.appeal!.id : s.selected.decision, reason: s.reason.trim() });
    const generation = ++this.generation;
    this.patch({ busy: true, frozen: command, failure: null, saved: false, retrying: !!s.frozen });
    try {
      const entry = await (this.review ? this.answer : this.submit).execute(command);
      if (this.disposed || generation !== this.generation) return;
      this.patch({ selected: entry, items: this.state.items.map(item => item.decision === entry.decision ? entry : item), frozen: null, reason: '', saved: true, retrying: false, notice: this.state.notice + 1 });
    } catch (error) { if (generation === this.generation) this.fail(error); }
    finally { if (generation === this.generation) this.patch({ busy: false }); }
  }
  dispose() { this.disposed = true; ++this.generation; this.listeners.clear(); this.state = Object.freeze({ ...this.state, items: [], selected: null, reason: '', frozen: null }); }
}
