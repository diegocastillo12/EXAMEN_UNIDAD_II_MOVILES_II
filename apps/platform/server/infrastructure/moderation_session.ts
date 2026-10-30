import { createCipheriv,createDecipheriv,createHash,randomBytes } from 'node:crypto';
import { ModerationFailure } from '../../shared/features/moderation/domain/moderation.ts';
import type { PrivateSession } from '../features/moderation/data/server_moderation_repository.ts';
import type { ModerationConfig } from '../features/moderation/data/moderation_source.ts';
export function moderationConfiguration(env:NodeJS.ProcessEnv):ModerationConfig {
  try {
    const url=new URL(env.SUPABASE_URL||'invalid:');const local=['localhost','127.0.0.1','[::1]'].includes(url.hostname);
    const key=env.SUPABASE_PUBLISHABLE_KEY||'',sessionSecret=env.MODERATION_SESSION_SECRET||'';
    if((url.protocol!=='https:' && !(url.protocol==='http:'&&local)) || url.username || url.password || !['','/'].includes(url.pathname) || url.search || url.hash || sessionSecret.length<32 || key.length<20 ||
      !(key.startsWith('sb_publishable_') || (key.startsWith('eyJ') && JSON.parse(Buffer.from(key.split('.')[1]||'','base64url').toString()).role==='anon')))throw Error();
    const origin=new URL(env.PUBLIC_WEB_ORIGIN||'https://entrehuellas.app');
    if(origin.protocol!=='https:' && !(origin.protocol==='http:' && ['localhost','127.0.0.1','[::1]'].includes(origin.hostname)))throw Error();
    return {url:url.origin,key,sessionSecret,secure:origin.protocol==='https:'};
  }catch{throw new ModerationFailure('unavailable');}
}
export function sealSession(session:PrivateSession,secret:string):string {
  const iv=randomBytes(12),cipher=createCipheriv('aes-256-gcm',createHash('sha256').update(secret).digest(),iv);
  cipher.setAAD(Buffer.from('entrehuellas:moderation:v1'));
  const ciphertext=Buffer.concat([cipher.update(JSON.stringify(session),'utf8'),cipher.final()]);
  return Buffer.concat([iv,cipher.getAuthTag(),ciphertext]).toString('base64url');
}
export function openSession(value:string|undefined,secret:string):PrivateSession|null {
  try{
    if(!value || value.length>6000)return null;
    const raw=Buffer.from(value,'base64url'),decipher=createDecipheriv('aes-256-gcm',createHash('sha256').update(secret).digest(),raw.subarray(0,12));
    decipher.setAAD(Buffer.from('entrehuellas:moderation:v1'));decipher.setAuthTag(raw.subarray(12,28));
    const s=JSON.parse(Buffer.concat([decipher.update(raw.subarray(28)),decipher.final()]).toString('utf8'));
    if(typeof s.actor!=='string'||typeof s.token!=='string'||typeof s.expiresAt!=='number'||s.expiresAt<=Date.now()||s.expiresAt>Date.now()+3600001)return null;
    return {actor:s.actor,token:s.token,expiresAt:s.expiresAt};
  }catch{return null;}
}
