import { statistics, statisticsError } from '../../utils/statistics';
export default defineEventHandler(async event => {
  try { return { allowed: await (await statistics(event)).access.execute() }; }
  catch (error) { return statisticsError(event, error); }
});
