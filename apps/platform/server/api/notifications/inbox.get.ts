import { notifications,notificationError } from '../../utils/notifications';
import { InboxFailure } from '../../../shared/features/notifications/domain/inbox';
export default defineEventHandler(async event=>{try {
  const cursor=getQuery(event).before;if (cursor!==undefined && typeof cursor!=='string') throw new InboxFailure('invalid');
  return await (await notifications(event)).read.execute(cursor??null);
} catch(e) {return notificationError(event,e);}});
