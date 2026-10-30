import { InboxFailure,notificationId } from '../domain/inbox.ts';
import type { InboxPage } from '../domain/inbox.ts';
export function inboxDto(raw:unknown,server=false):InboxPage {
  try {
    const value=raw as Record<string,unknown>;
    if (!value || !Array.isArray(value.items) || value.items.length>50) throw Error();
    const cursor=server?value.next:value.cursor;
    const items=value.items.map((item:Record<string,unknown>) => {
      const date=server?item.created_at:item.createdAt;
      if (typeof item.title!=='string' || !item.title.trim() || item.title.length>500 || typeof date!=='string' || !Number.isFinite(Date.parse(date))) throw Error();
      if (!server && typeof item.read!=='boolean') throw Error();
      return Object.freeze({id:notificationId(item.id),title:item.title,createdAt:date,read:server?item.read_at!=null:item.read as boolean});
    });
    if (new Set(items.map(i=>i.id)).size!==items.length) throw Error();
    return Object.freeze({items:Object.freeze(items),cursor:cursor===null?null:notificationId(cursor)});
  } catch {throw new InboxFailure('unavailable');}
}
