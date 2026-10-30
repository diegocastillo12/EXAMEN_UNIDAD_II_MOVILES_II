import { ModerationFailure, uuid } from '../../../../shared/features/moderation/domain/moderation.ts';
import type { ModerationRepository, ModerationCommand, QueueCursor, ReviewerSession } from '../../../../shared/features/moderation/domain/moderation.ts';
import { decisionDto, detailDto, pageDto } from '../../../../shared/features/moderation/data/moderation_dto.ts';
import { ModerationSource } from './moderation_source.ts';
export type PrivateSession = {actor:string;token:string;expiresAt:number};
export class ServerModerationRepository implements ModerationRepository {
  established: PrivateSession | null;
  constructor(private readonly source: ModerationSource, session:PrivateSession|null) {this.established=session;}
  private async authorized():Promise<PrivateSession> {
    const session=this.established;
    if(!session || session.expiresAt<=Date.now())throw new ModerationFailure('unauthenticated');
    const user=await this.source.user(session.token) as {id?:unknown;is_anonymous?:unknown};
    if(user.id!==session.actor || user.is_anonymous===true)throw new ModerationFailure('unauthenticated');
    if(await this.source.rpc(session.token,'require_content_reviewer')!==session.actor)throw new ModerationFailure('forbidden');
    return session;
  }
  async session():Promise<ReviewerSession> {const s=await this.authorized();return {actor:s.actor,expiresAt:s.expiresAt};}
  async login(email:string,password:string):Promise<ReviewerSession> {
    return this.establish(await this.source.password(email,password));
  }
  async exchange(code:string,verifier:string):Promise<ReviewerSession>{return this.establish(await this.source.exchange(code,verifier));}
  private async establish(value:unknown):Promise<ReviewerSession>{
    const raw=value as {access_token?:unknown;expires_in?:unknown;user?:{id?:unknown}};
    if(typeof raw.access_token!=='string' || raw.access_token.length>4096 || !uuid(raw.user?.id) || typeof raw.expires_in!=='number' || !Number.isFinite(raw.expires_in) || raw.expires_in<1)throw new ModerationFailure('unavailable');
    this.established={actor:raw.user.id,token:raw.access_token,expiresAt:Date.now()+Math.min(3600,raw.expires_in)*1000};
    try{return await this.session();}catch(error){await this.source.logout(this.established.token);this.established=null;throw error;}
  }
  async logout(){const s=this.established;this.established=null;if(s)await this.source.logout(s.token);}
  async list(resolved:boolean,cursor:QueueCursor|null){const s=await this.authorized();return pageDto(await this.source.rpc(s.token,'list_moderation_reports',{p_resolved:resolved,p_before_time:cursor?.time??null,p_before_id:cursor?.id??null}));}
  async read(id:string){const s=await this.authorized();return detailDto(await this.source.rpc(s.token,'read_moderation_report',{p_id:id}));}
  async decide(c:ModerationCommand){const s=await this.authorized();return decisionDto(await this.source.rpc(s.token,'decide_content_report',{p_command:c.id,p_report:c.report,p_report_version:c.reportVersion,p_resource_version:c.resourceVersion,p_action:c.action,p_reason:c.reason}));}
  async evidence(id:string){const s=await this.authorized();return this.source.rpc(s.token,'read_moderation_evidence',{p_id:id},1500000);}
}
