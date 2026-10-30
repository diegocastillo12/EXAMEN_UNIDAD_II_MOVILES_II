import { RecoveryFailure } from '../domain/recovery.ts';
import type { ExploreCases, ReadMyPets, SaveMyPet, AddPetPhoto, ReadOpenSearches, PublishRecoveryReport, ReadReportDraft, SaveReportDraft, ClearReportDraft, LocalReportDraft, CaseCard, Pet, PetDraft, ReportDraft, ReportPhoto, ReportReceipt, ExploreQuery } from '../domain/recovery.ts';
type State = Readonly<{ loading: boolean; refreshing: boolean; busy: boolean; petsLoading: boolean; targetsLoading: boolean; petsReady: boolean; targetsReady: boolean; petsFailure: RecoveryFailure | null; targetsFailure: RecoveryFailure | null; items: readonly CaseCard[]; pets: readonly Pet[]; targets: readonly CaseCard[]; cursor: string | null; failure: RecoveryFailure | null; notice: number; receipt: ReportReceipt | null }>;
export class RecoveryViewModel {
  state: State = { loading: true, refreshing: false, busy: false, petsLoading: false, targetsLoading: false, petsReady: false, targetsReady: false, petsFailure: null, targetsFailure: null, items: [], pets: [], targets: [], cursor: null, failure: null, notice: 0, receipt: null };
  private listeners = new Set<(state: State) => void>(); private generation = 0; private disposed = false;
  constructor(private readonly explore: ExploreCases, private readonly readPets: ReadMyPets, private readonly save: SaveMyPet, private readonly addPhoto: AddPetPhoto, private readonly searches: ReadOpenSearches, private readonly publish: PublishRecoveryReport, private readonly readDraft:ReadReportDraft, private readonly saveDraft:SaveReportDraft, private readonly clearDraft:ClearReportDraft) {}
  subscribe(listener: (state: State) => void) { this.listeners.add(listener); return () => { this.listeners.delete(listener); }; }
  private update(change: Partial<State>) { if (this.disposed) return; this.state = { ...this.state, ...change }; for (const listener of this.listeners) listener(this.state); }
  private fail(e: unknown) { this.update({ failure: e instanceof RecoveryFailure ? e : new RecoveryFailure('unavailable'), notice: this.state.notice + 1 }); }
  async load(section: 'explore' | 'pets' | 'report', query: ExploreQuery = { kind: 'all', species: 'all', status: 'active' }, more = false) {
    if (this.disposed || this.state.busy || this.state.refreshing) return;
    if (section === 'report') {
      if (this.state.petsLoading || this.state.targetsLoading) return;
      ++this.generation;
      this.update({ loading: false });
      await Promise.all([this.loadReportSource('pets'), this.loadReportSource('targets')]);
      return;
    }
    const generation = ++this.generation;
    this.update({ refreshing: !this.state.loading, failure: null });
    try {
      if (section === 'explore') { const page = await this.explore.execute(query, more ? this.state.cursor : null); if (generation === this.generation) this.update({ items: more ? [...this.state.items, ...page.items.filter(p => !this.state.items.some(i => i.id === p.id && i.source === p.source))] : page.items, cursor: page.cursor }); }
      else { const pets = await this.readPets.execute(); if (generation === this.generation) this.update({ pets }); }
    } catch (e) { if (generation === this.generation) this.fail(e); }
    finally { if (generation === this.generation) this.update({ loading: false, refreshing: false }); }
  }
  async loadReportSource(source: 'pets' | 'targets') {
    const loading = source === 'pets' ? 'petsLoading' : 'targetsLoading';
    const ready = source === 'pets' ? 'petsReady' : 'targetsReady';
    const failure = source === 'pets' ? 'petsFailure' : 'targetsFailure';
    if (this.disposed || this.state.busy || this.state[loading]) return;
    const generation = this.generation, previousFailure = this.state[failure];
    this.update({ [loading]: true });
    try {
      // Publish each result as soon as it arrives; unrelated reads never hold it.
      if (source === 'pets') {
        const pets = await this.readPets.execute();
        if (this.disposed || generation !== this.generation) return;
        this.update({ pets, [ready]: true, [failure]: null });
      } else {
        const targets = await this.searches.execute();
        if (this.disposed || generation !== this.generation) return;
        this.update({ targets, [ready]: true, [failure]: null });
      }
      if (this.state.failure === previousFailure) this.update({ failure: this.state[source === 'pets' ? 'targetsFailure' : 'petsFailure'] });
    } catch (e) {
      if (this.disposed || generation !== this.generation) return;
      const error = e instanceof RecoveryFailure ? e : new RecoveryFailure('unavailable');
      this.update({ [failure]: error }); this.fail(error);
    } finally {
      if (!this.disposed && generation === this.generation) this.update({ [loading]: false });
    }
  }
  async savePet(draft: PetDraft) {
    if (this.state.busy) return null; this.update({ busy: true, failure: null });
    try { const pet = await this.save.execute(draft); this.update({ pets: [pet, ...this.state.pets.filter(p => p.id !== pet.id)] }); return pet; }
    catch (e) { this.fail(e); return null; } finally { this.update({ busy: false }); }
  }
  async uploadPetPhoto(pet: string, photo: ReportPhoto) {
    if (this.state.busy) return false; this.update({ busy: true, failure: null });
    try { await this.addPhoto.execute(pet, photo); const pets = await this.readPets.execute(); this.update({ pets }); return true; }
    catch (e) { this.fail(e); return false; } finally { this.update({ busy: false }); }
  }
  async send(draft: ReportDraft, photos: readonly ReportPhoto[]) {
    if (this.state.busy || this.state.receipt) return;
    this.update({ busy: true, failure: null });
    try { const receipt = await this.publish.execute(draft, photos); ++this.generation; this.update({ receipt, petsLoading: false, targetsLoading: false }); try { await this.clearDraft.execute(); } catch { /* Published receipt remains authoritative; stale draft can retry the same ID. */ } }
    catch (e) { this.fail(e); } finally { this.update({ busy: false }); }
  }
  async restoreDraft() { const generation = this.generation; try { const value = await this.readDraft.execute(); return !this.disposed && generation === this.generation ? value : null; } catch(e) { if (!this.disposed && generation === this.generation) this.fail(e); return null; } }
  async remember(value:LocalReportDraft) { try { await this.saveDraft.execute(value); return true; } catch(e) { this.fail(e); return false; } }
  dispose() { this.disposed = true; this.generation++; this.listeners.clear(); this.state = { ...this.state, pets: [], items: [], targets: [], receipt: null, petsReady: false, targetsReady: false, petsLoading: false, targetsLoading: false, petsFailure: null, targetsFailure: null }; }
}
