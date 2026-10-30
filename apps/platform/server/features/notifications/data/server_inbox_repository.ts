import type { InboxRepository } from '../../../../shared/features/notifications/domain/inbox.ts';
import { inboxDto } from '../../../../shared/features/notifications/data/inbox_dto.ts';
import { InboxSource } from './inbox_source.ts';
export class ServerInboxRepository implements InboxRepository {
  constructor(private readonly source:InboxSource) {}
  async list(cursor:string|null) {return inboxDto(await this.source.rpc('list_notifications',{p_before:cursor}),true);}
  async markRead(id:string) {await this.source.rpc('mark_notification_read',{p_id:id});}
}
