import { userBlocks,blockError } from '../../utils/user_blocks';
import { moderationBody } from '../../utils/moderation';
export default defineEventHandler(async event=>{try {
  const actions=await userBlocks(event),body=await moderationBody(event);return {entry:await actions.prepare.execute({kind:body.kind as 'lost'|'found'|'sighting',id:body.id as string})};
}catch(e){return blockError(event,e);}});
