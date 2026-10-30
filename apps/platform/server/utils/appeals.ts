import type { H3Event } from 'h3';
import { account, accountCookie, accountError } from './account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { ReadAppeals, SubmitAppeal, AnswerAppeal, AppealFailure } from '../../shared/features/appeals/domain/appeals';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession } from '../infrastructure/account_session';
import { ServerAppealsRepository } from '../features/appeals/data/server_appeals_repository';
import { AppealsSource } from '../features/appeals/data/appeals_source';
export async function appeals(event: H3Event) {
  const session = await account(event, true).access.session();
  if (!session.profile.onboardingCompleted) throw new AccessFailure('forbidden');
  const config = moderationConfiguration(process.env), privateSession = openAccountSession(getCookie(event, accountCookie), config.sessionSecret);
  if (!privateSession || privateSession.actor !== session.actor) throw new AccessFailure('unauthenticated');
  const repository = new ServerAppealsRepository(new AppealsSource(config, privateSession.token));
  return { read: new ReadAppeals(repository), submit: new SubmitAppeal(repository), answer: new AnswerAppeal(repository) };
}
export function appealError(event: H3Event, error: unknown) { return accountError(event, error instanceof AppealFailure ? new AccessFailure(error.kind) : error); }
