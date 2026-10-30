import sharp from 'sharp';
import { moderationFixture,ordinary,moderator } from './moderation_fixture.mjs';
export async function inboxFixture() {
  const jpeg=await sharp({create:{width:80,height:80,channels:3,background:'#459ff6'}}).jpeg().toBuffer();
  let failList=false,failMark=false,avatar=true;const calls=[];
  const items=[{id:'9007199254740993',title:'Hay novedades en un caso que sigues',created_at:'2026-10-20T12:00:00Z',read_at:null},{id:'9007199254740992',title:'Una búsqueda ha sido actualizada',created_at:'2026-10-19T12:00:00Z',read_at:'2026-10-19T13:00:00Z'},{id:'42',title:'Nuevo caso cerca de tu ubicación',created_at:'2026-10-18T12:00:00Z',read_at:null}];
  const send=(res,value,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(value));};
  const server=await moderationFixture(jpeg,{async handle(req,res){
    const actor=req.headers.authorization==='Bearer '+'m'.repeat(30)?moderator:ordinary;
    if (req.url?.startsWith('/storage/v1/object/authenticated/profile-avatars/')) {
      calls.push({kind:'avatar',actor,path:req.url});
      if (!avatar) {send(res,{error:'missing'},404);return true;}
      res.writeHead(200,{'Content-Type':'image/jpeg'});res.end(jpeg);return true;
    }
    if (!['/rest/v1/rpc/list_notifications','/rest/v1/rpc/mark_notification_read'].includes(req.url)) return false;
    const chunks=[];for await(const chunk of req) chunks.push(chunk);const body=JSON.parse(Buffer.concat(chunks).toString());
    calls.push({kind:req.url.endsWith('list_notifications')?'list':'mark',actor,body});
    if (req.url.endsWith('list_notifications')) {
      if (failList) {send(res,{message:'PRIVATE_ERROR'},503);return true;}
      const page=actor===ordinary?items.filter(item=>body.p_before===null||BigInt(item.id)<BigInt(body.p_before)):[];
      send(res,{items:page.slice(0,2).map(item=>({...item,case_source:'lost',case_id:'PRIVATE_CASE',owner_id:'PRIVATE_OWNER',contact_phone:'PRIVATE_PHONE'})),next:page.length>2?page[1].id:null});return true;
    }
    if (failMark) {send(res,{message:'PRIVATE_MARK_ERROR'},503);return true;}
    const item=actor===ordinary?items.find(item=>item.id===body.p_id):null;
    if (!item) {send(res,{code:'42501'},403);return true;}
    item.read_at??='2026-10-21T12:00:00Z';res.writeHead(204);res.end();return true;
  }});
  return {...server,calls,failList(value){failList=value;},failMark(value){failMark=value;},avatar(value){avatar=value;}};
}
