import { appeals, appealError } from '../../utils/appeals';
import { moderationBody } from '../../utils/moderation';
import type { AppealCommand } from '../../../shared/features/appeals/domain/appeals';
export default defineEventHandler(async event => {
  try { const operations = await appeals(event); return await operations.submit.execute(await moderationBody(event) as unknown as AppealCommand); }
  catch (error) { return appealError(event, error); }
});
