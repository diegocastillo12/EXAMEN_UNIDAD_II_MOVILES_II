import { appeals, appealError } from '../../utils/appeals';
import { moderationBody } from '../../utils/moderation';
import { AppealFailure } from '../../../shared/features/appeals/domain/appeals';
export default defineEventHandler(async event => {
  try {
    const operations = await appeals(event), body = await moderationBody(event);
    if (typeof body.review !== 'boolean' || (body.cursor !== null && (typeof body.cursor !== 'object' || !body.cursor || Array.isArray(body.cursor)))) throw new AppealFailure('invalid');
    return await operations.read.execute(body.review, body.cursor as { time: string; id: string } | null);
  } catch (error) { return appealError(event, error); }
});
