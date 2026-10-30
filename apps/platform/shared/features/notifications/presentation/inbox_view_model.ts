import { InboxFailure } from '../domain/inbox.ts';
import type { InboxItem,ReadInbox,MarkNotificationRead } from '../domain/inbox.ts';
type InboxState=Readonly<{items:readonly InboxItem[];cursor:string|null;loaded:boolean;loading:boolean;refreshing:boolean;appending:boolean;busy:string|null;failure:InboxFailure|null;notice:number}>;
export class InboxViewModel {
  state:InboxState={items:[],cursor:null,loaded:false,loading:false,refreshing:false,appending:false,busy:null,failure:null,notice:0};
  private listeners=new Set<(value:InboxState)=>void>();private disposed=false;private generation=0;
  constructor(private readonly read:ReadInbox,private readonly mark:MarkNotificationRead) {}
  subscribe(listener:(value:InboxState)=>void) {this.listeners.add(listener);return ()=>this.listeners.delete(listener);}
  private update(patch:Partial<InboxState>) {if(this.disposed)return;this.state=Object.freeze({...this.state,...patch});for(const listener of this.listeners)listener(this.state);}
  private fail(error:unknown) {
    const failure=error instanceof InboxFailure?error:new InboxFailure('unavailable');
    this.update({failure,notice:this.state.notice+1,...(['unauthenticated','conflict'].includes(failure.kind)?{items:[],cursor:null,loaded:false}:{})});
  }
  async load(more=false) {
    if(this.disposed || this.state.loading || this.state.refreshing || this.state.appending || this.state.busy || (more&&!this.state.cursor))return;
    const generation=++this.generation,cursor=more?this.state.cursor:null;
    this.update({loading:!this.state.loaded,refreshing:this.state.loaded&&!more,appending:more,failure:null});
    try {const page=await this.read.execute(cursor);if(this.disposed||generation!==this.generation)return;
      this.update({items:more?[...this.state.items,...page.items.filter(item=>!this.state.items.some(old=>old.id===item.id))]:page.items,cursor:page.cursor,loaded:true});
    } catch(e) {if(generation===this.generation)this.fail(e);}
    finally {if(generation===this.generation)this.update({loading:false,refreshing:false,appending:false});}
  }
  async markRead(id:string) {
    if(this.disposed || this.state.busy || this.state.loading || this.state.refreshing || this.state.appending || !this.state.items.some(item=>item.id===id&&!item.read))return;
    this.update({busy:id,failure:null});const generation=this.generation;
    try {await this.mark.execute(id);if(!this.disposed&&generation===this.generation)this.update({items:this.state.items.map(item=>item.id===id?{...item,read:true}:item)});}
    catch(e) {if(generation===this.generation)this.fail(e);}
    finally {if(generation===this.generation)this.update({busy:null});}
  }
  dispose() {this.disposed=true;this.generation++;this.listeners.clear();this.state={...this.state,items:[],cursor:null};}
}
