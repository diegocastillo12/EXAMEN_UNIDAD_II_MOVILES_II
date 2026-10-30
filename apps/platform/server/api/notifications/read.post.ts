import { notifications,notificationError } from '../../utils/notifications';
export default defineEventHandler(async event=>{try {
  const model=await notifications(event);const body=await readBody(event);
  await model.mark.execute(body?.id);return {ok:true};
} catch(e) {return notificationError(event,e);}});
