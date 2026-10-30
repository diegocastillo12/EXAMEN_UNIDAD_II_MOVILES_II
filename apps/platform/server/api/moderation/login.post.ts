import { moderation,moderationBody,moderationError,clearModerationCookie } from '../../utils/moderation';
import { ModerationFailure } from '../../../shared/features/moderation/domain/moderation';
export default defineEventHandler(async event=>{
  clearModerationCookie(event);
  try{const body=await moderationBody(event);if(typeof body.email!=='string'||typeof body.password!=='string')throw new ModerationFailure('invalid');
    const services=moderation(event,false),session=await services.access.login(body.email,body.password);services.save();return session;
  }catch(error){return moderationError(event,error);}
});
