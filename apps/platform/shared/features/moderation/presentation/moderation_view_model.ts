import { ModerationFailure } from '../domain/moderation.ts';
import type { AccessModeration, ReviewReports, DecideReport, ReviewerSession, ReportPage, ReportDetail, ModerationCommand, ModerationAction, DecisionReceipt } from '../domain/moderation.ts';
export type ModerationState = Readonly<{ stage: 'checking' | 'login' | 'queue' | 'detail'; session: ReviewerSession | null; busy: boolean; retrying: boolean; resolved: boolean; page: ReportPage | null; detail: ReportDetail | null; selected: string | null; reason: string; action: ModerationAction; frozen: ModerationCommand | null; receipt: DecisionReceipt | null; photo: boolean; failure: ModerationFailure | null; notice: number }>;
const initial = (): ModerationState => Object.freeze({ stage:'checking',session:null,busy:false,retrying:false,resolved:false,page:null,detail:null,selected:null,reason:'',action:'dismiss',frozen:null,receipt:null,photo:false,failure:null,notice:0 });
export class ModerationViewModel {
  state = initial();
  private generation = 0; private selection = 0; private disposed = false;
  private listeners = new Set<(state: ModerationState) => void>();
  constructor(private readonly access: AccessModeration, private readonly reports: ReviewReports, private readonly decision: DecideReport, private readonly newId: () => string) {}
  subscribe(listener: (value: ModerationState) => void) { this.listeners.add(listener); listener(this.state); return () => { this.listeners.delete(listener); }; }
  private emit(patch: Partial<ModerationState>) { if (!this.disposed) { this.state = Object.freeze({...this.state,...patch}); for (const listener of this.listeners) listener(this.state); } }
  private failure(error: unknown) {
    const failure = error instanceof ModerationFailure ? error : new ModerationFailure('unavailable');
    if (failure.kind === 'unauthenticated' || failure.kind === 'forbidden') {
      ++this.generation; this.emit({...initial(),stage:'login',failure,notice:this.state.notice+1});
    } else this.emit({busy:false,failure,notice:this.state.notice+1});
  }
  async checkSession() {
    const generation = ++this.generation; this.emit({...initial()});
    try { const session = await this.access.session(); if (generation !== this.generation || this.disposed) return; this.emit({session,stage:'queue'}); await this.load(); }
    catch (error) { if (generation === this.generation && !this.disposed) { this.emit({stage:'login'}); if (!(error instanceof ModerationFailure) || error.kind !== 'unauthenticated') this.failure(error); } }
  }
  async login(email: string, password: string) {
    if (this.state.busy || this.disposed) return;
    const generation = ++this.generation; this.emit({busy:true,failure:null});
    try { const session = await this.access.login(email,password); if (generation !== this.generation || this.disposed) return; this.emit({...initial(),session,stage:'queue'}); await this.load(); }
    catch (error) { if (generation === this.generation) this.failure(error); }
  }
  async logout() {
    ++this.generation; this.emit({...initial(),stage:'login',busy:true});
    try { await this.access.logout(); this.emit({busy:false}); }
    catch (error) { this.failure(error); }
  }
  async load(resolved = this.state.resolved, more = false) {
    if (this.state.busy || !this.state.session || this.disposed) return;
    const generation = this.generation, cursor = more ? this.state.page?.next : null;
    if (more && !cursor) return;
    const previous = this.state.page;
    this.emit({busy:true,resolved,stage:'queue',detail:null,reason:'',frozen:null,receipt:null,photo:false,failure:null,...(resolved !== this.state.resolved ? {page:null} : {})});
    try { const page = await this.reports.list(resolved,cursor ?? null); if (generation !== this.generation || this.disposed) return;
      const items = more && previous ? [...previous.items,...page.items].filter((item,i,all)=>all.findIndex(other=>other.id===item.id)===i) : page.items;
      this.emit({busy:false,page:Object.freeze({items:Object.freeze(items),next:page.next})});
    } catch(error) { if (generation === this.generation) this.failure(error); }
  }
  async open(id: string) {
    if (this.state.busy || !this.state.session || this.disposed) return;
    const generation = this.generation, selection = ++this.selection;
    this.emit({stage:'detail',busy:true,detail:null,selected:id,reason:'',action:'dismiss',retrying:false,frozen:null,receipt:null,photo:false,failure:null});
    try { const detail = await this.reports.read(id); if (generation === this.generation && selection === this.selection) this.emit({busy:false,detail}); }
    catch(error) { if (generation === this.generation && selection === this.selection) this.failure(error); }
  }
  async refreshDetail() {
    const s=this.state;if(s.busy || !s.selected || !s.session || this.disposed)return;
    const generation=this.generation;this.emit({busy:true,failure:null});
    try{const detail=await this.reports.read(s.selected);if(generation===this.generation)this.emit({busy:false,detail,frozen:null,receipt:null,photo:false});}
    catch(error){if(generation===this.generation)this.failure(error);}
  }
  edit(reason: string, action = this.state.action) { if (!this.state.busy && !this.state.frozen && !this.state.receipt) this.emit({reason,action,failure:null}); }
  requestPhoto() { if (this.state.detail?.resource?.hasPhoto) this.emit({photo:true}); }
  photoFailed() { this.emit({photo:false}); this.failure(new ModerationFailure('unavailable')); }
  async decide() {
    const s = this.state;
    if (s.busy || !s.session || !s.detail || s.receipt || s.failure?.kind === 'conflict' || this.disposed) return;
    const generation = this.generation;
    const command = s.frozen ?? Object.freeze({id:this.newId(),report:s.detail.id,reportVersion:s.detail.reportVersion,resourceVersion:s.detail.resourceVersion,action:s.action,reason:s.reason});
    this.emit({busy:true,failure:null,frozen:command,retrying:!!s.frozen});
    try { const receipt = await this.decision.execute(command);
      if (generation !== this.generation || this.disposed) return;
      if (receipt.actor !== s.session.actor || receipt.id !== command.id || receipt.report !== command.report || receipt.action !== command.action || receipt.reason !== command.reason.trim() || receipt.reportVersion !== command.reportVersion+1 || receipt.resourceVersion !== command.resourceVersion+1) throw new ModerationFailure('unavailable');
      this.emit({busy:false,receipt,frozen:null,notice:this.state.notice+1});
    } catch(error) { if (generation === this.generation) { if (error instanceof ModerationFailure && error.kind === 'invalid') this.emit({frozen:null}); this.failure(error); } }
  }
  clear() { ++this.generation; this.emit({...initial(),stage:'login'}); }
  invalidate() { ++this.generation; this.emit(initial()); }
  dispose() { this.disposed=true; ++this.generation; this.listeners.clear(); this.state=initial(); }
}
