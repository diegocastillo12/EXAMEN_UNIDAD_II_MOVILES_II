import { BlockFailure } from '../domain/user_blocks.ts';
import type { ReadUserBlocks,PrepareUserBlock,SetUserBlock,BlockEntry,BlockTarget,BlockChange } from '../domain/user_blocks.ts';
type State=Readonly<{ loading:boolean;refreshing:boolean;busy:boolean;items:readonly BlockEntry[];next:string|null;target:BlockEntry|null;pending:BlockChange|null;failure:BlockFailure|null;notice:number;confirmed:boolean }>;
export class UserBlockViewModel {
  state:State={loading:true,refreshing:false,busy:false,items:[],next:null,target:null,pending:null,failure:null,notice:0,confirmed:false};
  private listeners=new Set<(state:State)=>void>();private generation=0;private disposed=false;
  constructor(private readonly read:ReadUserBlocks,private readonly prepare:PrepareUserBlock,private readonly set:SetUserBlock,private readonly target:BlockTarget|null) {}
  subscribe(listener:(state:State)=>void) {this.listeners.add(listener);return()=>{this.listeners.delete(listener);};}
  private update(change:Partial<State>) {if(this.disposed)return;this.state={...this.state,...change};for(const listener of this.listeners)listener(this.state);}
  private fail(error:unknown) {
    const failure=error instanceof BlockFailure?error:new BlockFailure('unavailable');
    this.update({failure,notice:this.state.notice+1,confirmed:false,...(['unauthenticated','forbidden','conflict'].includes(failure.kind)?{items:[],next:null,target:null,pending:null}:{} )});
  }
  async load(more=false) {
    if(this.disposed || this.state.busy || this.state.refreshing || this.state.pending || (more && !this.state.next))return;
    const generation=++this.generation;this.update({refreshing:true,failure:null,confirmed:false});
    try {
      const [page,target]=await Promise.all([this.read.execute(more?this.state.next:null),!more && this.target?this.prepare.execute(this.target):Promise.resolve(this.state.target)]);
      if(generation!==this.generation || this.disposed)return;
      this.update({items:more?[...this.state.items,...page.items.filter(e=>!this.state.items.some(old=>old.id===e.id))]:page.items,next:page.next,target});
    }catch(e){if(generation===this.generation)this.fail(e);}
    finally{if(generation===this.generation)this.update({loading:false,refreshing:false});}
  }
  async change(entry:BlockEntry,enabled:boolean) {
    if(this.disposed || this.state.busy || this.state.refreshing || this.state.failure?.kind==='conflict' || (this.state.pending && (this.state.pending.entry.id!==entry.id || this.state.pending.enabled!==enabled)))return;
    const pending=this.state.pending??{entry,enabled},generation=this.generation;
    this.update({busy:true,pending,failure:null,confirmed:false});
    try {
      const result=await this.set.execute(pending);
      if(this.disposed || generation!==this.generation)return;
      this.update({target:this.state.target?.id===result.id?result:this.state.target,items:result.enabled?[result,...this.state.items.filter(e=>e.id!==result.id)]:this.state.items.filter(e=>e.id!==result.id),pending:null,confirmed:true,notice:this.state.notice+1});
    }catch(e){if(generation===this.generation){this.fail(e);if(this.state.failure?.kind!=='unavailable')this.update({pending:null});}}
    finally{if(generation===this.generation)this.update({busy:false});}
  }
  dispose(){this.disposed=true;this.generation++;this.listeners.clear();this.state={...this.state,items:[],next:null,target:null,pending:null};}
}
