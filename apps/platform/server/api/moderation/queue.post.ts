import { moderation,moderationBody,moderationError } from '../../utils/moderation';
import { ModerationFailure,uuid } from '../../../shared/features/moderation/domain/moderation';
export default defineEventHandler(async event=>{
  try{const services=moderation(event),body=await moderationBody(event);
    if(typeof body.resolved!=='boolean')throw new ModerationFailure('invalid');
    const cursor=body.cursor as {time?:unknown;id?:unknown}|null;
    if(cursor!=null && (typeof cursor.time!=='string'||!Number.isFinite(Date.parse(cursor.time))||!uuid(cursor.id)))throw new ModerationFailure('invalid');
    return await services.reports.list(body.resolved,cursor?{time:cursor.time as string,id:cursor.id as string}:null);
  }catch(error){return moderationError(event,error);}
});
