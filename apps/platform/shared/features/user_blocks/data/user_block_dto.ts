import { BlockFailure,blockId } from '../domain/user_blocks.ts';
import type { BlockEntry,BlockPage } from '../domain/user_blocks.ts';
export function blockEntry(raw:unknown):BlockEntry {
  if (!raw || typeof raw!=='object' || Array.isArray(raw)) throw new BlockFailure('unavailable');
  const r=raw as Record<string,unknown>;
  if (!blockId(r.id) || typeof r.label!=='string' || !r.label.length || [...r.label].length>120 || typeof r.enabled!=='boolean' || !Number.isInteger(r.version) || (r.version as number)<0 || (r.version as number)>2147483647) throw new BlockFailure('unavailable');
  return { id:r.id,label:r.label,enabled:r.enabled,version:r.version as number };
}
export function blockPage(raw:unknown):BlockPage {
  if (!raw || typeof raw!=='object' || Array.isArray(raw)) throw new BlockFailure('unavailable');
  const r=raw as Record<string,unknown>;
  if (!Array.isArray(r.items) || r.items.length>20 || (r.next!==null && !blockId(r.next))) throw new BlockFailure('unavailable');
  const items=r.items.map(blockEntry);
  if (items.some(e=>!e.enabled) || new Set(items.map(e=>e.id)).size!==items.length) throw new BlockFailure('unavailable');
  return { items,next:r.next as string|null };
}
