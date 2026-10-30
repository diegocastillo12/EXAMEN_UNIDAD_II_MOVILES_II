import { RecoveryFailure } from '../domain/recovery.ts';
import type { ReadCasePublication, CasePublication } from '../domain/recovery.ts';
type State=Readonly<{busy:boolean;data:CasePublication|null;failure:RecoveryFailure['kind']|null;notice:number}>;
export class PublicationViewModel {
  state:State={busy:false,data:null,failure:null,notice:0};private generation=0;private disposed=false;private listeners=new Set<(s:State)=>void>();
  constructor(private readonly read:ReadCasePublication){}
  subscribe(l:(s:State)=>void){this.listeners.add(l);return()=>{this.listeners.delete(l);};}
  private emit(p:Partial<State>){if(this.disposed)return;this.state={...this.state,...p};for(const l of this.listeners)l(this.state);}
  async load(source:'lost'|'found',id:string){if(this.disposed||this.state.busy)return;const g=++this.generation;this.emit({busy:true,failure:null});try{const data=await this.read.execute(source,id);if(g===this.generation)this.emit({data,busy:false});}catch(e){if(g===this.generation)this.emit({data:null,busy:false,failure:e instanceof RecoveryFailure?e.kind:'unavailable',notice:this.state.notice+1});}}
  invalidate(){++this.generation;this.emit({data:null,busy:false,failure:null});}
  dispose(){this.invalidate();this.disposed=true;this.listeners.clear();}
}
