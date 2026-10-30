<script setup lang="ts">
// Animation core copied from sader-panel/src/components/ui/pretty-modal.tsx.
// Vue supplies mounting/lifecycle; the actual GSAP Flip calls and ease are Sader's.
import gsap from 'gsap';
import { Flip } from 'gsap/Flip';
import { CustomEase } from 'gsap/CustomEase';
import type { OriginSource } from '~/utils/origin_transition';
import { originMotionFrame } from '~/utils/origin_motion_contract';
const app = useNuxtApp(),motion = app.$originTransition;
const PRETTY_MODAL_EASE = 'M0,0 C0.305,0.206 0.116,0.567 0.3,0.8 0.394,0.921 0.491,1 1,1';
const MORPH_DURATION = 0.7;
let stop:(()=>void)|undefined;
let restoreClosed:((restore:boolean)=>void)|undefined;
let disposed = false;
function cancel() { stop?.(); }
// A route can add/remove scrollbars and emit visualViewport.resize without
// resizing the window. That notification must not finish a just-started Flip.
const viewportSize = () => ({width:window.innerWidth,height:window.innerHeight,visualHeight:window.visualViewport?.height??window.innerHeight,scale:window.visualViewport?.scale??1});
let viewport:ReturnType<typeof viewportSize>|undefined;
function resize() {
  const next=viewportSize(),previous=viewport;viewport=next;
  if(previous&&(next.width!==previous.width||next.height!==previous.height||Math.abs(next.visualHeight-previous.visualHeight)>1||next.scale!==previous.scale))cancel();
}
function completeReturn(restore = true) { const cleanup=restoreClosed;restoreClosed=undefined;cleanup?.(restore); }
function play(source:OriginSource, reverse:boolean) {
  cancel();completeReturn();
  viewport=viewportSize();
  const target = document.querySelector<HTMLElement>('[data-origin-content]:not([data-origin-underlay] *)');
  const body = target?.querySelector<HTMLElement>(':scope > .origin-page-body');
  if (!target || !body || disposed || matchMedia('(prefers-reduced-motion: reduce)').matches) return Promise.resolve();
  const rect = source.element.isConnected ? source.element.getBoundingClientRect() : source.bounds;
  const radius=source.borderRadius.includes('%')?Math.min(rect.width,rect.height)*parseFloat(source.borderRadius)/100:Math.min(parseFloat(source.borderRadius)||0,rect.width/2,rect.height/2);
  const ghost = document.createElement('span');
  const flipId = 'entre-huellas-origin';
  ghost.dataset.flipId = flipId;
  ghost.setAttribute('aria-hidden','true');
  Object.assign(ghost.style,{position:'fixed',left:`${rect.x}px`,top:`${rect.y}px`,width:`${rect.width}px`,height:`${rect.height}px`,visibility:'hidden',pointerEvents:'none',borderRadius:`${radius/rect.width*100}% / ${radius/rect.height*100}%`});
  document.body.append(ghost);
  const state = Flip.getState(ghost);
  const style = target.style.cssText,bodyStyle = body.style.cssText;
  const priorFlipId = target.getAttribute('data-flip-id');
  const bounds = target.getBoundingClientRect();
  const bodyBounds=body.getBoundingClientRect();
  const sourceVisibility=source.element.style.visibility;
  source.element.style.visibility='hidden';
  const identity=document.createElement('span');
  identity.dataset.originIdentity='';identity.setAttribute('aria-hidden','true');
  Object.assign(identity.style,{position:'absolute',left:'50%',top:'50%',width:`${source.bounds.width}px`,height:`${source.bounds.height}px`,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:'10px',color:source.color,fontFamily:'Arial, sans-serif',fontSize:'.78125rem',fontWeight:'600',pointerEvents:'none',transformOrigin:'center'});
  if(source.icon){const icon=source.icon.cloneNode(true) as HTMLElement;Object.assign(icon.style,{width:`${source.iconWidth}px`,height:`${source.iconHeight}px`,flexShrink:'0'});identity.append(icon);}
  if(source.label){const label=document.createElement('span');label.textContent=source.label;identity.append(label);}
  target.append(identity);
  // Keep the document height/scroll position while the actual surface occupies
  // the viewport, as pretty-modal-fullscreen does in Sader. No cloned content.
  const placeholder=document.createElement('div');
  placeholder.setAttribute('aria-hidden','true');
  Object.assign(placeholder.style,{width:`${bounds.width}px`,height:`${bounds.height}px`,margin:getComputedStyle(target).margin,pointerEvents:'none'});
  target.before(placeholder);
  const header=target.closest('.reader-shell')?.querySelector<HTMLElement>('.site-header');
  const headerStyle=header?.style.cssText;
  if(header)Object.assign(header.style,{position:'relative',zIndex:'9'});
  target.dataset.flipId = flipId;
  target.dataset.originAnimating = reverse ? 'closing' : 'opening';
  target.inert = true;
  gsap.set(body,{visibility:'visible',opacity:1,position:'absolute',left:bodyBounds.x,top:bodyBounds.y,width:bodyBounds.width});
  // Opaque page paint inside the morph occludes the outgoing route only within
  // its actual transformed bounds. The content scales with that same surface.
  const shell=target.closest<HTMLElement>('.reader-shell');
  const shellBounds=shell?.getBoundingClientRect();
  const background=shell?getComputedStyle(shell).getPropertyValue('--page-background'):'linear-gradient(#fff,#fff)';
  gsap.set(target,{visibility:'visible',overflow:'hidden',position:'fixed',left:0,top:0,width:'100dvw',height:'100dvh',maxWidth:'100dvw',maxHeight:'100dvh',minHeight:0,padding:0,margin:0,'--origin-source-fill':reverse?'transparent':source.backgroundColor,backgroundImage:`linear-gradient(var(--origin-source-fill),var(--origin-source-fill)),${background}`,backgroundSize:`100% 100%, ${shellBounds?.width??innerWidth}px ${shellBounds?.height??innerHeight}px`,backgroundPosition:`0 0, ${shellBounds?.x??0}px ${shellBounds?.y??0}px`,borderRadius:'0% / 0%',zIndex:8});
  return new Promise<void>(resolve => {
    let tween:gsap.core.Timeline|undefined;
    let finished = false;
    const finish = () => {
      if (finished) return;
      finished = true;tween?.kill();ghost.remove();placeholder.remove();identity.remove();
      source.element.style.visibility=sourceVisibility;
      if(header)header.style.cssText=headerStyle??'';
      target.classList.remove('pretty-modal-opening','pretty-modal-closing');
      target.style.cssText = style;body.style.cssText = bodyStyle;
      target.removeAttribute('data-origin-animating');
      if (priorFlipId === null) target.removeAttribute('data-flip-id'); else target.setAttribute('data-flip-id',priorFlipId);
      target.inert = false;
      if(reverse && !disposed){
        // PrettyModal calls dialog.close() here. Keep the outgoing page hidden
        // until routing commits, so restoring Flip's styles cannot flash it.
        target.style.visibility='hidden';target.style.opacity='0';target.inert=true;
        restoreClosed=restore=>{if(restore){target.style.cssText=style;target.inert=false;}};
      }
      stop = undefined;resolve();
    };
    stop = finish;
    // PrettyModal: same flip-id, same from/to, scale:true, same custom ease,
    // same duration and onComplete cleanup. No old-page snapshot or fake host.
    const updateIdentity=()=>{
      const progress=tween?.progress()??0,value=reverse?1-progress:progress;
      const box=target.getBoundingClientRect();
      const inverseX=innerWidth/Math.max(box.width,.1),inverseY=innerHeight/Math.max(box.height,.1);
      identity.style.transform=`translate(-50%,-50%) scale(${inverseX},${inverseY})`;
      const shape=gsap.parseEase('entre-huellas-pretty-modal')(progress);
      const visualRadius=radius*(reverse?shape:1-shape);
      // Compensate both scale axes, like Flutter's ClipRRect radius in screen
      // coordinates. Flip's shorthand interpolation mixed px and percentages.
      target.style.borderRadius=`${visualRadius*inverseX}px / ${visualRadius*inverseY}px`;
      identity.style.opacity=String(originMotionFrame(value).source);
    };
    const options = {targets:target,scale:true,ease:'entre-huellas-pretty-modal',toggleClass:reverse ? 'pretty-modal-closing' : 'pretty-modal-opening',duration:MORPH_DURATION,onUpdate:updateIdentity,onComplete:finish};
    tween = reverse ? Flip.to(state,options) : Flip.from(state,options);
    tween.fromTo(target,{'--origin-source-fill':reverse?'transparent':source.backgroundColor},{'--origin-source-fill':reverse?source.backgroundColor:'transparent',duration:MORPH_DURATION,ease:'entre-huellas-pretty-modal'},0);
    updateIdentity();
  });
}
onMounted(() => {
  gsap.registerPlugin(Flip,CustomEase);
  CustomEase.create('entre-huellas-pretty-modal',PRETTY_MODAL_EASE);
  document.querySelectorAll('.origin-transition-hold,.origin-transition-host,.origin-transition-previous').forEach(node => node.remove());
  motion.setPlayer(play,completeReturn);
  viewport=viewportSize();
  window.addEventListener('resize',resize);
  window.visualViewport?.addEventListener('resize',resize);
  preference = matchMedia('(prefers-reduced-motion: reduce)');preference.addEventListener('change',cancel);
});
let preference:MediaQueryList|undefined;
watch(() => app.$navigationActor.value,cancel);
onBeforeUnmount(() => {disposed=true;cancel();completeReturn();motion.setPlayer(undefined);window.removeEventListener('resize',resize);window.visualViewport?.removeEventListener('resize',resize);preference?.removeEventListener('change',cancel);});
</script>
<template><span hidden data-origin-engine="sader-gsap-flip" /></template>
