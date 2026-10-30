import type { H3Event } from 'h3';
import { account,accountCookie,accountError } from './account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { ReadUserBlocks,PrepareUserBlock,SetUserBlock,BlockFailure } from '../../shared/features/user_blocks/domain/user_blocks';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession } from '../infrastructure/account_session';
import { ServerUserBlockRepository } from '../features/user_blocks/data/server_user_block_repository';
import { UserBlockSource } from '../features/user_blocks/data/user_block_source';
export async function userBlocks(event:H3Event) {
  const session=await account(event,true).access.session();
  if(!session.profile.onboardingCompleted)throw new AccessFailure('forbidden');
  const config=moderationConfiguration(process.env),privateSession=openAccountSession(getCookie(event,accountCookie),config.sessionSecret);
  if(!privateSession || privateSession.actor!==session.actor)throw new AccessFailure('unauthenticated');
  const repository=new ServerUserBlockRepository(new UserBlockSource(config,privateSession.token));
  return {read:new ReadUserBlocks(repository),prepare:new PrepareUserBlock(repository),set:new SetUserBlock(repository)};
}
export function blockError(event:H3Event,error:unknown) {return accountError(event,error instanceof BlockFailure?new AccessFailure(error.kind):error);}
