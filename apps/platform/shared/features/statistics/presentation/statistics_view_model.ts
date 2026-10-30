import { StatisticsFailure } from '../domain/statistics.ts';
import type { PilotStatistics, StatisticsIssue, ReadPilotStatistics, ReadStatisticsAccess } from '../domain/statistics.ts';
export type StatisticsState = Readonly<{
  from: string; to: string; busy: boolean; allowed: boolean | null; data: PilotStatistics | null;
  failure: StatisticsIssue | null; notice: number;
}>;
export class StatisticsViewModel {
  state: StatisticsState;
  private generation = 0;
  private disposed = false;
  private listeners = new Set<(state: StatisticsState) => void>();
  constructor(private readonly access: ReadStatisticsAccess, private readonly read: ReadPilotStatistics, today: string) {
    this.state = Object.freeze({ from: today.slice(0, 7) + '-01', to: today, busy: false, allowed: null, data: null, failure: null, notice: 0 });
  }
  subscribe(listener: (state: StatisticsState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(patch: Partial<StatisticsState>) {
    if (this.disposed) return;
    this.state = Object.freeze({ ...this.state, ...patch });
    for (const listener of this.listeners) listener(this.state);
  }
  edit(field: 'from' | 'to', value: string) { if (!this.state.busy) this.emit({ [field]: value, failure: null }); }
  private fail(error: unknown) {
    const kind = error instanceof StatisticsFailure ? error.kind : 'unavailable';
    const revoked = ['unauthenticated', 'forbidden', 'conflict'].includes(kind);
    this.emit({ busy: false, failure: kind, notice: this.state.notice + 1, ...(revoked ? { data: null, allowed: false } : {}) });
  }
  async checkAccess() {
    if (this.disposed || this.state.busy) return;
    const generation = ++this.generation;
    this.emit({ busy: true, allowed: null, data: null, failure: null });
    try { const allowed = await this.access.execute(); if (generation === this.generation) this.emit({ busy: false, allowed }); }
    catch (error) { if (generation === this.generation) this.fail(error); }
  }
  async load() {
    if (this.disposed || this.state.busy) return;
    const generation = ++this.generation;
    this.emit({ busy: true, failure: null });
    try {
      const data = await this.read.execute({ from: this.state.from, to: this.state.to });
      if (generation === this.generation) this.emit({ busy: false, allowed: true, data });
    } catch (error) { if (generation === this.generation) this.fail(error); }
  }
  invalidate() { ++this.generation; this.emit({ busy: false, data: null, allowed: null, failure: null }); }
  dispose() { this.invalidate(); this.disposed = true; this.listeners.clear(); }
}
