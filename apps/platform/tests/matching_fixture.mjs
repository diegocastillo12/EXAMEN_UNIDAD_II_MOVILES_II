import sharp from 'sharp';
import {moderationFixture,ordinary}from'./moderation_fixture.mjs';
export const lost='a0000000-0000-4000-8000-000000000071',found='a0000000-0000-4000-8000-000000000072';
const photo='a0000000-0000-4000-8000-000000000073';
export async function matchingFixture(options={}){
 let failed=false,revoked=false,empty=false,authFailed=false;const reviews=[];
 const jpeg=await sharp({create:{width:12,height:12,channels:3,background:'#cccccc'}}).jpeg().toBuffer();
 const vector=[1,...Array(511).fill(0)];
 const indexed=new Map();
 const snapshot=(id,source)=>({id,source,owner:ordinary,kind:source==='lost'?'own_loss':'independent_found',revision:(source==='lost'?'a':'b').repeat(32),name:source==='lost'?'Luna':'Mascota encontrada',species:'dog',occurred_at:'2026-10-24T12:00:00Z',latitude:-18.005,longitude:-70.005,photos:[{id:photo,path:`${ordinary}/${id}/${photo}.jpg`,hash:'c'.repeat(64),embedding:options.uncached?(indexed.get(id)||null):vector}]});
 const send=(res,v,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(v));};
 const server=await moderationFixture(jpeg,{env:{...(options.modelDirectory?{MATCH_MODEL_DIRECTORY:options.modelDirectory}:{}),...(options.env||{})},handle:async(req,res)=>{
  if(req.url==='/auth/v1/user'&&authFailed){send(res,{},503);return true;}
  if(req.url==='/auth/v1/user'&&!['Bearer '+'o'.repeat(30),'Bearer '+'m'.repeat(30)].includes(req.headers.authorization)){send(res,{},401);return true;}
  const rpc=req.url?.split('/rest/v1/rpc/')[1];
  if(['list_my_match_searches','read_case_match_context','store_case_match_embedding','review_case_match'].includes(rpc)){
   const chunks=[];for await(const chunk of req)chunks.push(chunk);const p=JSON.parse(Buffer.concat(chunks).toString());
   if(p.p_actor!==ordinary||revoked){send(res,{code:'42501',message:'PRIVATE'},403);return true;}
   if(failed){send(res,{message:'PRIVATE'},503);return true;}
   if(rpc==='store_case_match_embedding'){if(!Array.isArray(p.p_embedding)||p.p_embedding.length!==512){send(res,{code:'22023'},422);return true;}indexed.set(p.p_case,p.p_embedding);send(res,null);return true;}
   if(rpc==='list_my_match_searches'){send(res,[{source:'lost',id:lost,name:'Luna',species:'dog'}]);return true;}
   if(rpc==='read_case_match_context'){send(res,{anchor:snapshot(lost,'lost'),candidates:empty?[]:[snapshot(found,'found')],reviews});return true;}
   reviews.push({source:'found',id:found,revision:'b'.repeat(32),decision:p.p_decision});send(res,null);return true;
  }
  if(rpc==='read_recovery_report'){
   for await(const _ of req){};send(res,[{id:found,status:'active',report_kind:'independent_found',species:'dog',traits:'Orejas blancas y pelaje claro',occurred_at:'2026-10-24T12:00:00Z',latitude:-18.005,longitude:-70.005,custody:'with_me',photos:[{path:`${ordinary}/${found}/${photo}.jpg`}]}]);return true;
  }
  return false;
 }});
 return{...server,fail:v=>{failed=v;},authFail:v=>{authFailed=v;},revoke:v=>{revoked=v;},empty:v=>{empty=v;},reviews,indexed};
}
