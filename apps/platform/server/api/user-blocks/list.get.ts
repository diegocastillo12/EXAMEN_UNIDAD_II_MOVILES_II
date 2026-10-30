import { userBlocks,blockError } from '../../utils/user_blocks';
import { BlockFailure } from '../../../shared/features/user_blocks/domain/user_blocks';
export default defineEventHandler(async event=>{try {
  const before=getQuery(event).before;if(before!==undefined && typeof before!=='string')throw new BlockFailure('invalid');
  return await (await userBlocks(event)).read.execute(before??null);
}catch(e){return blockError(event,e);}});
