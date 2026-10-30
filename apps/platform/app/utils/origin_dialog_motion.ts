import {ORIGIN_ENTER_MS,ORIGIN_EXIT_MS,originMotionFrame} from './origin_motion_contract';
export function playOriginDialog(dialog:HTMLDialogElement,content:HTMLElement,identity:HTMLElement,origin:HTMLElement|null|undefined,reverse:boolean,showSource:boolean) {
  const end=dialog.getBoundingClientRect(),start=origin?.isConnected?origin.getBoundingClientRect():null;
  const animations:Animation[]=[];
  if(!start || matchMedia('(prefers-reduced-motion: reduce)').matches) return {finished:Promise.resolve(),cancel:()=>{}};
  const radius=getComputedStyle(dialog).borderTopLeftRadius,initialRadius=Math.min(start.width,start.height)/2;
  const frames=Array.from({length:101},(_,i)=>{const value=reverse?1-i/100:i/100;return{offset:i/100,...originMotionFrame(value)};});
  identity.replaceChildren();
  if(showSource){
    const original=origin?.querySelector('svg,img');const icon=original?.cloneNode(true) as Element|undefined;
    if(icon){for(const node of [icon,...icon.querySelectorAll('*')]){node.removeAttribute('id');for(const attr of [...node.attributes])if(/^on/i.test(attr.name))node.removeAttribute(attr.name);}identity.append(icon);}
  }
  Object.assign(content.style,{width:`${end.width}px`,transformOrigin:'top left'});
  const options:KeyframeAnimationOptions={duration:reverse?ORIGIN_EXIT_MS:ORIGIN_ENTER_MS,fill:'both',easing:'linear'};
  const lerp=(a:number,b:number,p:number)=>a+(b-a)*p;
  animations.push(dialog.animate(frames.map(({offset,shape})=>({offset,margin:'0px',left:`${lerp(start.left,end.left,shape)}px`,top:`${lerp(start.top,end.top,shape)}px`,width:`${lerp(start.width,end.width,shape)}px`,height:`${lerp(start.height,end.height,shape)}px`,maxHeight:'none',overflow:'hidden',borderRadius:`${lerp(initialRadius,parseFloat(radius)||0,shape)}px`})),options));
  animations.push(content.animate(frames.map(({offset,shape,content:opacity})=>({offset,opacity,transform:`scale(${lerp(start.width/end.width,1,shape)})`})),options));
  animations.push(identity.animate(frames.map(({offset,source:opacity})=>({offset,opacity:showSource?opacity:0})),options));
  const cleanup=()=>{animations.forEach(a=>a.cancel());identity.replaceChildren();content.style.removeProperty('width');content.style.removeProperty('transform-origin');};
  return {finished:Promise.all(animations.map(a=>a.finished.catch(()=>{}))).then(()=>{}),cancel:cleanup};
}
