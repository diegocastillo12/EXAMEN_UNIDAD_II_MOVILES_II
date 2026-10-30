import { ReaderFailure } from '../domain/case.ts';
import type { PublicCase } from '../domain/case.ts';
import type { ReadCase } from '../domain/read_case.ts';
export type ReaderState = Readonly<{ phase: PublicCase['state'] | 'loading' | 'error'; value: PublicCase | null; refreshing: boolean; notice: string | null; noticeId: number }>;
export class ReaderViewModel {
  state: ReaderState;
  private listeners = new Set<(state: ReaderState) => void>();
  private generation = 0;
  private slug?: string;
  private pending = false;
  private abort?: AbortController;
  constructor(private readonly reader: ReadCase, initial: PublicCase | null = null, slug?: string, failed = false) {
    this.slug = slug;
    this.state = Object.freeze({ phase: initial?.state || (failed ? 'error' : 'loading'), value: initial, refreshing: false, notice: failed ? 'unavailable' : null, noticeId: failed ? 1 : 0 });
  }
  subscribe(listener: (state: ReaderState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(state: ReaderState) { this.state = Object.freeze(state); for (const listener of this.listeners) listener(this.state); }
  async load(slug: string) {
    if (this.slug === slug && this.pending) return;
    const old = this.slug === slug ? this.state.value : null;
    this.slug = slug; this.abort?.abort(); this.abort = new AbortController();
    const generation = ++this.generation; this.pending = true;
    this.emit({ ...this.state, phase: old ? old.state : 'loading', value: old, refreshing: !!old, notice: null });
    try {
      const next = await this.reader.execute(slug, this.abort.signal);
      if (generation !== this.generation) return;
      const value = old && JSON.stringify(old) === JSON.stringify(next) ? old : next;
      this.emit({ ...this.state, phase: value.state, value, refreshing: false, notice: null });
    } catch (error) {
      if (generation !== this.generation) return;
      this.emit({ ...this.state, phase: old ? old.state : 'error', value: old, refreshing: false,
        notice: error instanceof ReaderFailure && error.kind === 'rate_limited' ? 'rate_limited' : 'unavailable', noticeId: this.state.noticeId + 1 });
    } finally { if (generation === this.generation) this.pending = false; }
  }
  dispose() { ++this.generation; this.abort?.abort(); this.listeners.clear(); }
}
