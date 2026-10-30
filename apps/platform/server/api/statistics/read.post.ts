import { statistics, statisticsError } from '../../utils/statistics';
import { moderationBody } from '../../utils/moderation';
import { statisticsPeriod } from '../../../shared/features/statistics/domain/statistics';
export default defineEventHandler(async event => {
  try {
    const operations = await statistics(event), body = await moderationBody(event);
    return await operations.read.execute(statisticsPeriod(body.from, body.to));
  } catch (error) { return statisticsError(event, error); }
});
