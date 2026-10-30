import type { H3Event } from 'h3';
import { account, accountError } from './account';
import { configuration } from '../infrastructure/config';
import { FindCaseMatches, ReadMatchSearches, ReviewCaseMatch, MatchFailure, matchId } from '../../shared/features/matching/domain/matching';
import { MatchingSource } from '../features/matching/data/matching_source';
import { ServerMatchingRepository } from '../features/matching/data/server_matching_repository';
import { ClipImageEncoder } from '../features/matching/data/clip_image_encoder';
export async function matching(event: H3Event, native=false) {
  const config=configuration(process.env);
  let actor: string;
  if (native) {
    const authorization=getHeader(event,'authorization')||'';
    if (!/^Bearer [A-Za-z0-9._-]{20,8192}$/.test(authorization)) throw new MatchFailure('unauthenticated');
    // Verify the token at Auth; decoding a supplied JWT is never authentication.
    const response=await fetch(config.url+'/auth/v1/user',{headers:{apikey:config.key,Authorization:authorization},redirect:'error',cache:'no-store',signal:AbortSignal.timeout(10000)});
    if (!response.ok) {await response.body?.cancel();throw new MatchFailure([401,403].includes(response.status)?'unauthenticated':'unavailable');}
    const reader=response.body?.getReader();if(!reader)throw new MatchFailure('unauthenticated');
    const chunks:Uint8Array[]=[];let size=0;
    try{while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>65536)throw new MatchFailure('unauthenticated');chunks.push(value);}}
    finally{await reader.cancel().catch(()=>{});}
    const user=JSON.parse(Buffer.concat(chunks).toString('utf8'));
    if (!matchId(user.id)||user.is_anonymous===true) throw new MatchFailure('unauthenticated');
    actor=user.id;
  } else {
    const session=await account(event,true).access.session();
    if (!session.profile.onboardingCompleted) throw new MatchFailure('forbidden');
    actor=session.actor;
  }
  const repository=new ServerMatchingRepository(new MatchingSource(config),new ClipImageEncoder(),actor);
  return {searches:new ReadMatchSearches(repository),find:new FindCaseMatches(repository),review:new ReviewCaseMatch(repository)};
}
export function matchingError(event:H3Event,error:unknown) {
  if (!(error instanceof MatchFailure)) return accountError(event,error);
  setResponseStatus(event, {invalid:422,unauthenticated:401,forbidden:403,conflict:409,unavailable:503,busy:429}[error.kind]);
  return {error:error.kind};
}
export async function matchingBody(event:H3Event) {
  if (!(getHeader(event,'content-type')||'').startsWith('application/json')) throw new MatchFailure('invalid');
  const req=event.node.req;
  const bytes=await new Promise<Buffer>((resolve,reject)=>{
    const chunks:Buffer[]=[];let size=0;
    const clean=()=>{clearTimeout(timer);req.off('data',data);req.off('end',end);req.off('error',fail);req.off('aborted',fail);};
    const fail=()=>{clean();reject(new MatchFailure('invalid'));};
    const data=(chunk:Buffer)=>{size+=chunk.length;if(size>4096){req.pause();fail();}else chunks.push(chunk);};
    const end=()=>{clean();resolve(Buffer.concat(chunks));};
    const timer=setTimeout(()=>{req.pause();fail();},10000);
    req.on('data',data);req.once('end',end);req.once('error',fail);req.once('aborted',fail);
  });
  try{return JSON.parse(bytes.toString('utf8'));}catch{throw new MatchFailure('invalid');}
}
