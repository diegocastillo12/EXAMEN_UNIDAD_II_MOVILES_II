import { moderation,moderationError } from '../../../utils/moderation';
export default defineEventHandler(async event=>{
  try{return await moderation(event).reports.read(getRouterParam(event,'id')||'');}catch(error){return moderationError(event,error);}
});
