import { MatchFailure } from '../domain/matching.ts';
import type { ReadMatchSearches, FindCaseMatches, ReviewCaseMatch, MatchResult, MatchSearch, MatchReview, ReviewCommand } from '../domain/matching.ts';
type State=Readonly<{loading:boolean;busy:boolean;searches:readonly MatchSearch[];selected:string;result:MatchResult|null;failure:MatchFailure['kind']|null;notice:number;saved:number}>;
export class MatchingViewModel {
  state:State={loading:true,busy:false,searches:[],selected:'',result:null,failure:null,notice:0,saved:0};
  private listeners=new Set<(s:State)=>void>();private generation=0;private disposed=false;private retryCommand:ReviewCommand|null=null;
  constructor(private readonly read:ReadMatchSearches,private readonly find:FindCaseMatches,private readonly review:ReviewCaseMatch){}
  subscribe(listener:(s:State)=>void){this.listeners.add(listener);return()=>{this.listeners.delete(listener);};}
  private emit(patch:Partial<State>){if(this.disposed)return;this.state={...this.state,...patch};for(const l of this.listeners)l(this.state);}
  private fail(error:unknown){const failure=error instanceof MatchFailure?error.kind:'unavailable';this.emit({failure,notice:this.state.notice+1,...(['forbidden','unauthenticated','conflict'].includes(failure)?{result:null}:{})});}
  async load(){if(this.disposed||this.state.busy)return;const generation=++this.generation;this.emit({loading:true,busy:true,failure:null});try{const searches=await this.read.execute();if(generation===this.generation)this.emit({searches,selected:searches.some(s=>s.ref.source+':'+s.ref.id===this.state.selected)?this.state.selected:searches[0]?searches[0].ref.source+':'+searches[0].ref.id:''});}catch(e){if(generation===this.generation)this.fail(e);}finally{if(generation===this.generation)this.emit({loading:false,busy:false});}}
  select(selected:string){if(this.state.busy||this.disposed)return;this.retryCommand=null;this.emit({selected,result:null,failure:null});}
  async search(){if(this.disposed||this.state.busy)return;const target=this.state.searches.find(s=>s.ref.source+':'+s.ref.id===this.state.selected);if(!target)return;const generation=++this.generation;this.retryCommand=null;this.emit({busy:true,failure:null});try{const result=await this.find.execute(target.ref);if(generation===this.generation)this.emit({result});}catch(e){if(generation===this.generation)this.fail(e);}finally{if(generation===this.generation)this.emit({busy:false});}}
  async decide(candidateId:string,decision:MatchReview,commandId:string){
    if(this.disposed||this.state.busy||!this.state.result)return;
    const result=this.state.result,candidate=result.candidates.find(c=>c.ref.id===candidateId);if(!candidate)return;
    const generation=++this.generation;
    const previous=this.retryCommand;
    const command=previous&&previous.candidate.id===candidateId&&previous.decision===decision?previous:{id:commandId,anchor:result.anchor,anchorRevision:result.revision,candidate:candidate.ref,candidateRevision:candidate.revision,decision,model:result.model};
    this.retryCommand=command;this.emit({busy:true,failure:null});
    try{await this.review.execute(command);if(generation===this.generation){this.retryCommand=null;this.emit({result:{...result,candidates:result.candidates.map(c=>c===candidate?{...c,review:decision}:c)},saved:this.state.saved+1});}}
    catch(e){if(generation===this.generation)this.fail(e);}finally{if(generation===this.generation)this.emit({busy:false});}
  }
  invalidate(){++this.generation;this.retryCommand=null;this.emit({searches:[],selected:'',result:null,loading:false,busy:false,failure:null});}
  dispose(){this.invalidate();this.disposed=true;this.listeners.clear();}
}
