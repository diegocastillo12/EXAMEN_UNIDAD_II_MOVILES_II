import type { H3Event } from 'h3';
import { account,accountCookie,accountError } from './account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { ReadInbox,MarkNotificationRead,InboxFailure } from '../../shared/features/notifications/domain/inbox';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession } from '../infrastructure/account_session';
import { ServerInboxRepository } from '../features/notifications/data/server_inbox_repository';
import { InboxSource } from '../features/notifications/data/inbox_source';
export async function notifications(event:H3Event) {
  const session=await account(event,true).access.session();
  if (!session.profile.onboardingCompleted) throw new AccessFailure('forbidden');
  const config=moderationConfiguration(process.env),privateSession=openAccountSession(getCookie(event,accountCookie),config.sessionSecret);
  if (!privateSession || privateSession.actor!==session.actor) throw new AccessFailure('unauthenticated');
  const repository=new ServerInboxRepository(new InboxSource(config,privateSession.token));
  return {read:new ReadInbox(repository),mark:new MarkNotificationRead(repository)};
}
export function notificationError(event:H3Event,error:unknown) {
  return accountError(event,error instanceof InboxFailure?new AccessFailure(error.kind):error);
}
