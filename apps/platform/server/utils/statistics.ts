import type { H3Event } from 'h3';
import { account, accountCookie, accountError } from './account';
import { AccessFailure } from '../../shared/features/access/domain/access';
import { ReadPilotStatistics, ReadStatisticsAccess, StatisticsFailure } from '../../shared/features/statistics/domain/statistics';
import { moderationConfiguration } from '../infrastructure/moderation_session';
import { openAccountSession } from '../infrastructure/account_session';
import { StatisticsSource } from '../features/statistics/data/statistics_source';
import { ServerStatisticsRepository } from '../features/statistics/data/server_statistics_repository';
export async function statistics(event: H3Event, bind = true) {
  const session = await account(event, bind).access.session();
  if (!session.profile.onboardingCompleted) throw new AccessFailure('forbidden');
  const config = moderationConfiguration(process.env);
  const privateSession = openAccountSession(getCookie(event, accountCookie), config.sessionSecret);
  if (!privateSession || privateSession.actor !== session.actor) throw new AccessFailure('unauthenticated');
  const repository = new ServerStatisticsRepository(new StatisticsSource(config, privateSession.token), session.actor);
  return { access: new ReadStatisticsAccess(repository), read: new ReadPilotStatistics(repository) };
}
export function statisticsError(event: H3Event, error: unknown) { return accountError(event, error instanceof StatisticsFailure ? new AccessFailure(error.kind) : error); }
