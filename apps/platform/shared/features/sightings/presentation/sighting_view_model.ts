import { SightingFailure } from '../domain/sighting.ts';
import type { SightingDraft, SightingPoint, SightingReceipt, SubmitSighting, LocateSighting } from '../domain/sighting.ts';
export type SightingState = Readonly<{ working: boolean; locked: boolean; locating: boolean; point: SightingPoint | null; receipt: SightingReceipt | null; failure: SightingFailure | null; noticeId: number }>;
export class SightingViewModel {
  state: SightingState = Object.freeze({ working: false, locked: false, locating: false, point: null, receipt: null, failure: null, noticeId: 0 });
  private listeners = new Set<(value: SightingState) => void>();
  private attempted: SightingDraft | null = null;
  private disposed = false;
  private locationGeneration = 0;
  constructor(private readonly submit: SubmitSighting, private readonly slug: string, private readonly location?: LocateSighting) {}
  choosePoint(point: SightingPoint) {
    if (this.disposed || this.state.working || this.state.locked || this.state.receipt) return;
    ++this.locationGeneration; this.emit({ ...this.state, point: Object.freeze({ ...point }), locating: false });
  }
  async locate() {
    if (this.disposed || this.state.working || this.state.locked || this.state.locating || this.state.receipt || !this.location) return;
    const generation = ++this.locationGeneration;
    this.emit({ ...this.state, locating: true });
    try { const point = await this.location.execute(); if (generation === this.locationGeneration) this.emit({ ...this.state, locating: false, point }); }
    catch { if (generation === this.locationGeneration) this.emit({ ...this.state, locating: false, failure: new SightingFailure('location'), noticeId: this.state.noticeId + 1 }); }
  }
  subscribe(listener: (value: SightingState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(value: SightingState) { if (!this.disposed) { this.state = Object.freeze(value); for (const listener of this.listeners) listener(this.state); } }
  async send(draft: SightingDraft) {
    if (this.disposed || this.state.working || this.state.locating || this.state.receipt || this.state.failure?.kind === 'closed' || this.state.failure?.kind === 'conflict') return;
    const payload = this.state.locked && this.attempted ? this.attempted : Object.freeze({ ...draft, point: draft.point ? Object.freeze({ ...draft.point }) : null, photo: draft.photo ? new Uint8Array(draft.photo) : null });
    this.attempted = payload;
    this.emit({ ...this.state, working: true, failure: null });
    try { const receipt = await this.submit.execute(this.slug, payload); this.attempted = null; this.emit({ ...this.state, working: false, locked: false, receipt }); }
    catch (error) {
      const failure = error instanceof SightingFailure ? error : new SightingFailure('unavailable');
      this.emit({ ...this.state, working: false, locked: failure.kind === 'unavailable', failure, noticeId: this.state.noticeId + 1 });
    }
  }
  dispose() { this.disposed = true; ++this.locationGeneration; this.listeners.clear(); this.attempted = null; }
}
