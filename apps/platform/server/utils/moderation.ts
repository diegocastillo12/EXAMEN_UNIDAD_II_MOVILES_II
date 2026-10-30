import type { H3Event } from 'h3';
import { AccessModeration,ReviewReports,DecideReport,ModerationFailure,uuid } from '../../shared/features/moderation/domain/moderation';
import { ModerationSource } from '../features/moderation/data/moderation_source';
import { ServerModerationRepository } from '../features/moderation/data/server_moderation_repository';
import { moderationConfiguration,openSession,sealSession } from '../infrastructure/moderation_session';
import { configuration } from '../infrastructure/config';
import { openAccountSession } from '../infrastructure/account_session';
const cookieName='eh_moderation';
export function moderation(event:H3Event,bind=true){
  const config=moderationConfiguration(process.env),general=getCookie(event,'eh_access');
  const session=general?openAccountSession(general,config.sessionSecret):openSession(getCookie(event,cookieName),config.sessionSecret);
  if(bind && (!session || getHeader(event,'x-moderation-actor')!==session.actor))throw new ModerationFailure('unauthenticated');
  const repository=new ServerModerationRepository(new ModerationSource(config),session);
  return {repository,access:new AccessModeration(repository),reports:new ReviewReports(repository),decision:new DecideReport(repository),
    save(){const s=repository.established;if(!s)throw new ModerationFailure('unauthenticated');const sealed=sealSession(s,config.sessionSecret);if(sealed.length>3800)throw new ModerationFailure('unavailable');setCookie(event,cookieName,sealed,{httpOnly:true,secure:config.secure,sameSite:'strict',path:'/api/moderation',maxAge:Math.max(1,Math.floor((s.expiresAt-Date.now())/1000))});},
  };
}
export async function readModerationSession(event:H3Event){
  // No cookie means no session, independently of backend availability/configuration.
  // A supplied cookie still follows full decryption, Auth and role validation.
  if(!getCookie(event,cookieName)&&!getCookie(event,'eh_access'))throw new ModerationFailure('unauthenticated');
  return moderation(event,false).access.session();
}
export function clearModerationCookie(event:H3Event){deleteCookie(event,cookieName,{path:'/api/moderation',httpOnly:true,sameSite:'strict',secure:process.env.PUBLIC_WEB_ORIGIN?.startsWith('https://')===true});}
export function moderationError(event:H3Event,error:unknown){
  const kind=error instanceof ModerationFailure?error.kind:'unavailable';
  if(kind==='unauthenticated'||kind==='forbidden')clearModerationCookie(event);
  setResponseStatus(event,kind==='unauthenticated'?401:kind==='forbidden'?403:kind==='conflict'?409:kind==='invalid'?422:503);
  return {error:kind};
}
export async function moderationBody(event:H3Event):Promise<Record<string,unknown>>{
  if(getHeader(event,'content-type')?.split(';')[0]!=='application/json')throw new ModerationFailure('invalid');
  const chunks:Buffer[]=[];let count=0;
  const timeout=setTimeout(()=>event.node.req.destroy(),10000);
  try{for await(const chunk of event.node.req){const b=Buffer.from(chunk);count+=b.length;if(count>8192)throw new ModerationFailure('invalid');chunks.push(b);}
    const value=JSON.parse(Buffer.concat(chunks).toString('utf8'));if(!value||typeof value!=='object'||Array.isArray(value))throw Error();return value;
  }catch{throw new ModerationFailure('invalid');}finally{clearTimeout(timeout);}
}
export async function moderationEvidence(event:H3Event,id:string){
  if(!uuid(id))throw new ModerationFailure('invalid');
  const resource=await moderation(event,false).repository.evidence(id) as {jpeg?:unknown;bucket?:unknown;path?:unknown}|null;
  if(!resource){setResponseStatus(event,404);return null;}
  let bytes:Buffer;
  if(typeof resource.jpeg==='string')bytes=Buffer.from(resource.jpeg,'base64');
  else{
    if(!['pet-photo-renditions','found-photo-renditions'].includes(resource.bucket as string)||typeof resource.path!=='string'||!/^([0-9a-f-]{36}\/){2}[0-9a-f-]{36}\.jpg$/.test(resource.path))throw new ModerationFailure('unavailable');
    const config=configuration(process.env);
    const response=await fetch(`${config.url}/storage/v1/object/authenticated/${resource.bucket}/${resource.path}`,{headers:{apikey:config.key,...(config.key.startsWith('eyJ')?{Authorization:`Bearer ${config.key}`}:{})},redirect:'error',cache:'no-store',signal:AbortSignal.timeout(10000)});
    if(!response.ok || response.headers.get('content-type')?.split(';')[0]!=='image/jpeg')throw new ModerationFailure('unavailable');
    const reader=response.body?.getReader();if(!reader)throw new ModerationFailure('unavailable');
    const chunks:Uint8Array[]=[];let size=0;
    try{while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>2097152)throw new ModerationFailure('unavailable');chunks.push(value);}}finally{await reader.cancel().catch(()=>{});}
    bytes=Buffer.concat(chunks);
  }
  if(bytes.length<4||bytes.length>2097152||bytes[0]!==255||bytes[1]!==216||bytes.at(-2)!==255||bytes.at(-1)!==217)throw new ModerationFailure('unavailable');
  setHeader(event,'Content-Type','image/jpeg');return bytes;
}
