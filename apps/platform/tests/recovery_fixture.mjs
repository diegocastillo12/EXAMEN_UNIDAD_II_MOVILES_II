import sharp from 'sharp';
import { moderationFixture, ordinary, moderator } from './moderation_fixture.mjs';
export const petId='55555555-5555-4555-8555-555555555555', photoId='66666666-6666-4666-8666-666666666666', caseId='77777777-7777-4777-8777-777777777777';
export async function recoveryFixture(){
 const jpeg=await sharp({create:{width:80,height:60,channels:3,background:'#b5d5e9'}}).jpeg().toBuffer();
 const pets=new Map([[petId,{id:petId,owner_id:ordinary,name:'Luna',species:'dog',species_detail:null,size:'medium',sex:'female',age_months:24,traits:'Blanca con manchas',version:1,archived_at:null,pet_photos:[{id:photoId,status:'published',processed_at:'2026-10-20T12:00:00Z',created_at:'2026-10-20T12:00:00Z',is_primary:true}]}]]),reports=new Map(),prepared=new Map(),calls=[];
 let failed=false,ambiguous=false;
 const card={id:caseId,source:'lost',name:'Luna',pet_name:'Luna',species:'dog',traits:'Blanca con manchas',kind:'lost',report_kind:'own_loss',status:'active',occurred_at:'2026-10-19T12:00:00.000Z',latitude:-12.045,longitude:-77.045,cover_path:`${ordinary}/${petId}/${photoId}.jpg`,owner_id:'PRIVATE_OWNER',place_reference:'PRIVATE_REFERENCE',contact_phone:'PRIVATE_PHONE'};
 const send=(res,value,status=200)=>{res.writeHead(status,{'Content-Type':'application/json'});res.end(JSON.stringify(value));};
 const server=await moderationFixture(jpeg,{async handle(req,res){
  const actor=req.headers.authorization==='Bearer '+'m'.repeat(30)?moderator:ordinary;
  if(req.url?.startsWith('/rest/v1/pets?')){calls.push({path:req.url,actor});send(res,[...pets.values()].filter(p=>p.owner_id===actor));return true;}
  if(req.url?.startsWith('/storage/v1/object/authenticated/')){res.writeHead(200,{'Content-Type':'image/jpeg'});res.end(jpeg);return true;}
  if(req.url==='/functions/v1/pet-photo-process'){
   const chunks=[];for await(const b of req)chunks.push(b);const metadata=await sharp(Buffer.concat(chunks)).metadata();
   calls.push({path:req.url,actor,format:metadata.format,exif:!!metadata.exif});
   const id=req.headers['x-photo-id'],parent=req.headers['x-pet-id'],found=req.headers['x-found-case-id'];
   if(parent){const p=pets.get(parent);if(!p||p.owner_id!==actor){send(res,{},403);return true;}if(!p.pet_photos.some(p=>p.id===id))p.pet_photos.push({id,status:'published',processed_at:'2026-10-20T12:00:00Z',created_at:'2026-10-20T12:00:00Z'});send(res,{id,pet_id:parent,owner_id:actor,status:'published',processed_at:'2026-10-20T12:00:00Z'});}
   else send(res,{id,case_id:found,owner_id:actor,status:'ready',processed_at:'2026-10-20T12:00:00Z'});
   return true;
  }
  const rpc=req.url?.split('/rest/v1/rpc/')[1];if(!['explore_cases','list_open_recovery_searches','create_pet_v2','update_pet_v2','publish_lost_case','prepare_recovery_report','publish_recovery_report','read_recovery_pet_case','read_recovery_report'].includes(rpc))return false;
  const chunks=[];for await(const b of req)chunks.push(b);const body=JSON.parse(Buffer.concat(chunks).toString()||'{}');calls.push({rpc,body,actor});
  if(failed){send(res,{message:'PRIVATE_BACKEND_FAILURE'},503);return true;}
  if(rpc==='explore_cases'){const items=body.p_cursor?[]:[card];send(res,{items,next_cursor:body.p_cursor?null:{as_of:'2026-10-20T12:00:00Z',id:caseId,query:[]}});return true;}
  if(rpc==='list_open_recovery_searches'){send(res,[{...card,community:false},{...card,id:'88888888-8888-4888-8888-888888888888',name:'Gato comunitario',community:true}]);return true;}
  if(rpc.startsWith('read_recovery')){send(res,body.p_id===caseId?[{...card,photos:[{path:card.cover_path}]}]:[]);return true;}
  if(rpc==='create_pet_v2'||rpc==='update_pet_v2'){
   const current=pets.get(body.p_id);if(current&&(current.owner_id!==actor||(rpc==='update_pet_v2'&&current.version!==body.p_expected_version))){send(res,{},409);return true;}
   const p={id:body.p_id,owner_id:actor,name:body.p_name,species:body.p_species,species_detail:body.p_species_detail,size:body.p_size,sex:body.p_sex,age_months:body.p_age_months,traits:body.p_traits,version:(current?.version||0)+1,pet_photos:current?.pet_photos||[],archived_at:null};pets.set(p.id,p);send(res,[p]);return true;
  }
  if(rpc==='prepare_recovery_report'){prepared.set(body.p_id,body);send(res,null);return true;}
  if(rpc==='publish_lost_case'&&pets.get(body.p_pet_id)?.owner_id!==actor){send(res,{code:'42501'},403);return true;}
  if(!reports.has(body.p_id))reports.set(body.p_id,{id:body.p_id,owner_id:actor,status:'active'});
  if(ambiguous){ambiguous=false;send(res,{},503);return true;}
  send(res,[reports.get(body.p_id)]);return true;
 }});
 return {...server,jpeg,calls,pets,reports,fail:v=>{failed=v;},ambiguous:()=>{ambiguous=true;}};
}
