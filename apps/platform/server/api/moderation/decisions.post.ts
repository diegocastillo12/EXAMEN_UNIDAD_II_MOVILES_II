import { moderation,moderationBody,moderationError } from '../../utils/moderation';
import type { ModerationCommand } from '../../../shared/features/moderation/domain/moderation';
import { ModerationFailure } from '../../../shared/features/moderation/domain/moderation';
export default defineEventHandler(async event=>{
  try{const services=moderation(event),body=await moderationBody(event);
    if(typeof body.reason!=='string')throw new ModerationFailure('invalid');
    return await services.decision.execute(body as ModerationCommand);
  }catch(error){return moderationError(event,error);}
});
