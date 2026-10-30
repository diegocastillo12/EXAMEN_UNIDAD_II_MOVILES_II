import {moderationFixture,ordinary,moderator} from './moderation_fixture.mjs';
export const blockResource='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa42',blockId='cccccccc-cccc-4ccc-8ccc-cccccccccc42';
export async function userBlocksFixture(){
 let entry={id:blockId,label:'Reportante de Luna',enabled:false,version:0},ambiguous=false,failList=false,writes=0;const calls=[];
 const send=(res,value,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(value));};
 const server=await moderationFixture(undefined,{async handle(req,res){
  if(!['/rest/v1/rpc/prepare_user_block','/rest/v1/rpc/list_user_blocks','/rest/v1/rpc/set_user_block'].includes(req.url))return false;
  const actor=req.headers.authorization==='Bearer '+'m'.repeat(30)?moderator:ordinary;
  const chunks=[];for await(const b of req)chunks.push(b);const input=JSON.parse(Buffer.concat(chunks).toString());calls.push({actor,operation:req.url.split('/').at(-1),input});
  if(req.url.endsWith('list_user_blocks')){if(failList)send(res,{message:'PRIVATE_ERROR'},503);else send(res,{items:actor===ordinary && entry.enabled?[{...entry,owner_id:'PRIVATE_OWNER',blocked_id:'PRIVATE_TARGET'}]:[],next:null});return true;}
  if(req.url.endsWith('prepare_user_block')){if(input.p_resource!==blockResource)send(res,{code:'42501'},403);else send(res,actor===ordinary?{...entry,blocked_id:'PRIVATE_TARGET'}:null);return true;}
  if(actor!==ordinary || input.p_id!==entry.id){send(res,{code:'42501'},403);return true;}
  if(entry.version===input.p_version+1 && entry.enabled===input.p_enabled){send(res,entry);return true;}
  if(input.p_version!==entry.version){send(res,{message:'block_conflict'},409);return true;}
  if(entry.enabled!==input.p_enabled){entry={...entry,enabled:input.p_enabled,version:entry.version+1};writes++;}
  if(ambiguous){ambiguous=false;send(res,{message:'PRIVATE_AFTER_COMMIT'},503);}else send(res,entry);return true;
 }});
 return {...server,calls,entry:()=>entry,writes:()=>writes,failList:value=>{failList=value;},ambiguousBlock:()=>{ambiguous=true;}};
}
