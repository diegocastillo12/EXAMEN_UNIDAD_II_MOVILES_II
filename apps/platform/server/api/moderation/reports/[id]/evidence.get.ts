import { moderationEvidence,moderationError } from '../../../../utils/moderation';
export default defineEventHandler(async event=>{
  try{return await moderationEvidence(event,getRouterParam(event,'id')||'');}catch(error){return moderationError(event,error);}
});
