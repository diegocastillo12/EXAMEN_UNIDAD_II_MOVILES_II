import {moderationFixture,moderator,ordinary} from './moderation_fixture.mjs';
export const decision='cccccccc-cccc-4ccc-8ccc-000000000001';
export async function appealsFixture(){
 let item={decision,kind:'lost',resource:'cccccccc-cccc-4ccc-8ccc-000000000002',action:'hide',reason:'La publicación necesita revisión.',decidedAt:'2026-10-23T12:00:00Z',appeal:null};
 let fail=false,ambiguous=false,revoked=false;let submissions=0,answers=0;
 const send=(res,value,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(value));};
 const server=await moderationFixture(undefined,{handle:async(req,res)=>{
  if(!req.url?.match(/\/rpc\/(list_moderation_appeals|submit_moderation_appeal|answer_moderation_appeal)$/))return false;
  const chunks=[];for await(const chunk of req)chunks.push(chunk);const input=JSON.parse(Buffer.concat(chunks).toString());
  const actor=req.headers.authorization==='Bearer '+'m'.repeat(30)?moderator:ordinary;
  if((input.p_review||req.url.endsWith('answer_moderation_appeal'))&&(actor!==moderator||revoked)){send(res,{code:'42501'},403);return true;}
  if(fail){send(res,{message:'PRIVATE backend failure'},503);return true;}
  if(req.url.endsWith('list_moderation_appeals')){send(res,{items:input.p_review&&!item.appeal?[]:[item],next:null});return true;}
  if(req.url.endsWith('submit_moderation_appeal')){
   if(actor!==ordinary){send(res,{code:'42501'},403);return true;}
   if(item.appeal&&(item.appeal.id!==input.p_id||item.appeal.reason!==input.p_reason)){send(res,{message:'appeal_conflict'},400);return true;}
   if(!item.appeal){submissions++;item={...item,appeal:{id:input.p_id,reason:input.p_reason,submittedAt:'2026-10-23T12:10:00Z',answer:null}};}
  }else if(!item.appeal||item.appeal.id!==input.p_appeal){send(res,{code:'42501'},403);return true;}
  else if(!item.appeal.answer){answers++;item={...item,appeal:{...item.appeal,answer:{id:input.p_id,actor:moderator,reason:input.p_reason,answeredAt:'2026-10-23T12:20:00Z'}}};}
  if(ambiguous){ambiguous=false;send(res,{message:'PRIVATE committed but disconnected'},503);}else send(res,item);return true;
 }});
 return {...server,failAppeals:v=>fail=v,ambiguousAppeal:()=>ambiguous=true,revokeAppeals:v=>{revoked=v;server.revoke(v);},submissions:()=>submissions,answers:()=>answers};
}
