export type InboxIssue='invalid'|'unauthenticated'|'forbidden'|'conflict'|'unavailable';
export class InboxFailure extends Error { constructor(readonly kind:InboxIssue) {super(kind);} }
export type InboxItem=Readonly<{ id:string;title:string;createdAt:string;read:boolean }>;
export type InboxPage=Readonly<{items:readonly InboxItem[];cursor:string|null}>;
export interface InboxRepository { list(cursor:string|null):Promise<InboxPage>;markRead(id:string):Promise<void>; }
export function notificationId(value:unknown):string {
  if (typeof value!=='string' || !/^[1-9][0-9]{0,18}$/.test(value) || BigInt(value)>9223372036854775807n) throw new InboxFailure('invalid');
  return value;
}
export class ReadInbox {
  constructor(private readonly repository:InboxRepository) {}
  execute(cursor:string|null=null) {return this.repository.list(cursor===null?null:notificationId(cursor));}
}
export class MarkNotificationRead {
  constructor(private readonly repository:InboxRepository) {}
  execute(id:string) {return this.repository.markRead(notificationId(id));}
}
