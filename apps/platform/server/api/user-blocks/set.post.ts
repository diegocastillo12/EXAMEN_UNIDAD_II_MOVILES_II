import { userBlocks,blockError } from '../../utils/user_blocks';
import { moderationBody } from '../../utils/moderation';
export default defineEventHandler(async event=>{try {
  const actions=await userBlocks(event),body=await moderationBody(event);
  return await actions.set.execute({entry:{id:body.id as string,version:body.version as number,label:'',enabled:!body.enabled},enabled:body.enabled as boolean});
}catch(e){return blockError(event,e);}});
