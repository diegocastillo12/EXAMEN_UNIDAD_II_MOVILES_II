import { HttpInboxRepository } from '#shared/features/notifications/data/http_inbox_repository';
import { ReadInbox,MarkNotificationRead } from '#shared/features/notifications/domain/inbox';
import { InboxViewModel } from '#shared/features/notifications/presentation/inbox_view_model';
export default defineNuxtPlugin(()=>({provide:{inboxModel:(actor:string)=>{
  const repository=new HttpInboxRepository(actor);
  return new InboxViewModel(new ReadInbox(repository),new MarkNotificationRead(repository));
}}}));
