import { nextTick, readonly, shallowRef } from 'vue';
export type OriginSource = Readonly<{bounds:{x:number;y:number;width:number;height:number};element:HTMLElement;backgroundColor:string;borderRadius:string;color:string;icon:Element|null;iconWidth:number;iconHeight:number;label:string}>;
export type OriginPlayer = (source:OriginSource,reverse:boolean)=>Promise<void>;
function capture(element:HTMLElement):OriginSource {
  const {x,y,width,height}=element.getBoundingClientRect();
  const style=getComputedStyle(element);
  const original=element.querySelector('svg,img'),icon=original?.cloneNode(true) as Element|undefined;
  if(icon)for(const node of [icon,...icon.querySelectorAll('*')]){node.removeAttribute('id');for(const attr of [...node.attributes])if(/^on/i.test(attr.name))node.removeAttribute(attr.name);}
  const iconBounds=original?.getBoundingClientRect();
  return {bounds:{x,y,width,height},element,backgroundColor:style.backgroundColor,borderRadius:style.borderRadius,color:style.color,icon:icon??null,iconWidth:iconBounds?.width??24,iconHeight:iconBounds?.height??24,label:element.textContent?.trim()??''};
}
export function createOriginTransition(actor:()=>string|null=()=>null) {
  const pending=shallowRef<string|null>(null),busy=shallowRef(false);
  let player:OriginPlayer|undefined;
  let completeReturn:((restore?:boolean)=>void)|undefined;
  let record:{source:OriginSource;from:string;to:string}|null=null;
  let local:OriginSource|null=null;
  let releasePage:(()=>void)|undefined;
  let entering:HTMLElement|undefined;
  const release=()=>{releasePage?.();releasePage=undefined;entering?.classList.remove('origin-route-entering');entering=undefined;};
  const reduced=()=>matchMedia('(prefers-reduced-motion: reduce)').matches;
  return {
    pending:readonly(pending),busy:readonly(busy),
    // Vue keeps the actual outgoing route DOM until done(); no page snapshot.
    retainPage(element:Element,done:()=>void){
      if(!pending.value||!(element instanceof HTMLElement)){done();return;}
      releasePage?.();releasePage=undefined;
      const rect=element.getBoundingClientRect();
      element.dataset.originUnderlay='';element.inert=true;element.setAttribute('aria-hidden','true');
      Object.assign(element.style,{position:'fixed',left:`${rect.left}px`,top:`${rect.top}px`,width:`${rect.width}px`,margin:'0',zIndex:'0',pointerEvents:'none'});
      releasePage=()=>{done();};
    },
    preparePage(element:Element){
      if(pending.value&&element instanceof HTMLElement){entering=element;element.classList.add('origin-route-entering');}
    },
    setPlayer(value:OriginPlayer|undefined,complete?:((restore?:boolean)=>void)){player=value;completeReturn=complete;},
    async open(element:HTMLElement,action:()=>Promise<unknown>|unknown,options:{from:string;to:string;current?:()=>string}) {
      if(busy.value)return false;
      if(reduced()||!player){await action();return true;}
      const source=capture(element),identity=actor(),previous=document.querySelector('[data-origin-content]');
      pending.value=options.to;busy.value=true;
      try {
        const result=await action();
        if(result===false||actor()!==identity||(options.current&&options.current()!==options.to))return false;
        await nextTick();
        const deadline=performance.now()+2000;
        const destination=()=>{const node=document.querySelector('[data-origin-content]:not([data-origin-underlay] *)');return node&&(options.from===options.to||node!==previous);};
        while(!destination()&&actor()===identity&&performance.now()<deadline)await new Promise<void>(resolve=>requestAnimationFrame(()=>resolve()));
        if(!destination()||actor()!==identity||(options.current&&options.current()!==options.to))return false;
        if(!reduced())await player(source,false);
        if(actor()!==identity)return false;
        if(options.from!==options.to)record={source,from:options.from,to:options.to};else local=source;
        return true;
      } finally {release();pending.value=null;busy.value=false;}
    },
    async closeLocal(action:()=>Promise<unknown>|unknown){
      if(busy.value)return;
      const source=local;local=null;busy.value=true;
      try {if(source&&!reduced()&&player)await player(source,true);await action();await nextTick();}
      finally{completeReturn?.();busy.value=false;}
    },
    // Vue Router runs leave/dirty-form guards first. Keep the live page mounted
    // for Flip.to, just as PrettyModal closes only after onComplete.
    async beforeRouteChange(to:string,from:string){
      if(busy.value||!record||record.from!==to||record.to!==from)return;
      const source=record.source;record=null;
      if(reduced()||!player)return;
      busy.value=true;
      try{await player(source,true);}finally{busy.value=false;}
    },
    routeChanged(to:string,from:string,failed:boolean){completeReturn?.(failed);if(failed||busy.value)return;local=null;if(record&&(record.from!==to||record.to!==from))record=null;},
    clear(){completeReturn?.(false);release();record=null;local=null;pending.value=null;},
  };
}
