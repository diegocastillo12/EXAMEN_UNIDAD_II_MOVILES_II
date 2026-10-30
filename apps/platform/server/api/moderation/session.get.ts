import { readModerationSession,moderationError } from '../../utils/moderation';
export default defineEventHandler(async event=>{
  try{return await readModerationSession(event);}catch(error){return moderationError(event,error);}
});
