import { HttpUserBlockRepository } from '#shared/features/user_blocks/data/http_user_block_repository';
import { ReadUserBlocks,PrepareUserBlock,SetUserBlock } from '#shared/features/user_blocks/domain/user_blocks';
import type { BlockTarget } from '#shared/features/user_blocks/domain/user_blocks';
import { UserBlockViewModel } from '#shared/features/user_blocks/presentation/user_block_view_model';
export default defineNuxtPlugin(()=>({provide:{userBlockModel:(actor:string,target:BlockTarget|null)=>{
  const repository=new HttpUserBlockRepository(actor);
  return new UserBlockViewModel(new ReadUserBlocks(repository),new PrepareUserBlock(repository),new SetUserBlock(repository),target);
}}}));
