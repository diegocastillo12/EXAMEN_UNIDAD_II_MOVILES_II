// Flutter parity for Profile/Alerts dialogs. Web page morphs use Sader (ADR-125).
export const ORIGIN_ENTER_MS=320;
export const ORIGIN_EXIT_MS=260;
export const ORIGIN_EASING='cubic-bezier(.645,.045,.355,1)';
export const ORIGIN_SOURCE_END=.45;
export const ORIGIN_CONTENT_START=.65;
function cubic(value:number,x1:number,y1:number,x2:number,y2:number) {
  if(value<=0)return 0;if(value>=1)return 1;
  const axis=(t:number,a:number,b:number)=>3*(1-t)*(1-t)*t*a+3*(1-t)*t*t*b+t*t*t;
  let low=0,high=1;
  for(let i=0;i<24;i++){const middle=(low+high)/2;if(axis(middle,x1,x2)<value)low=middle;else high=middle;}
  return axis((low+high)/2,y1,y2);
}
export function originMotionFrame(value:number) {
  const progress=Math.max(0,Math.min(1,value));
  const shape=cubic(progress,.645,.045,.355,1);
  return {shape,source:1-cubic(Math.min(1,progress/ORIGIN_SOURCE_END),.645,.045,.355,1),content:cubic(Math.max(0,(progress-ORIGIN_CONTENT_START)/(1-ORIGIN_CONTENT_START)),.215,.61,.355,1)};
}
