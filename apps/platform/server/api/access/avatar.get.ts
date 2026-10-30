import { account,accountError } from '../../utils/account';
import { AccessFailure } from '../../../shared/features/access/domain/access';
import { ReadAccountAvatar } from '../../../shared/features/access/domain/account_avatar';
export default defineEventHandler(async event => {
  try {
    const model=account(event),session=await model.access.session();
    if (!session.profile.onboardingCompleted || getQuery(event).actor!==session.actor) throw new AccessFailure('forbidden');
    const bytes=await new ReadAccountAvatar(model.repository).execute();
    if (!bytes) {setResponseStatus(event,204);return '';}
    setHeader(event,'Content-Type','image/jpeg');return bytes;
  } catch(e) {return accountError(event,e);}
});
