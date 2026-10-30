export type BlockIssue = 'invalid'|'unauthenticated'|'forbidden'|'conflict'|'unavailable';
export class BlockFailure extends Error { constructor(readonly kind:BlockIssue) { super(kind); } }
export type BlockEntry = Readonly<{ id:string;label:string;enabled:boolean;version:number }>;
export type BlockTarget = Readonly<{ kind:'lost'|'found'|'sighting';id:string }>;
export type BlockPage = Readonly<{ items:readonly BlockEntry[];next:string|null }>;
export type BlockChange = Readonly<{ entry:BlockEntry;enabled:boolean }>;
export interface UserBlockRepository {
  list(before:string|null):Promise<BlockPage>;
  prepare(target:BlockTarget):Promise<BlockEntry|null>;
  set(change:BlockChange):Promise<BlockEntry>;
}
export const blockId=(id:unknown):id is string=>typeof id==='string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
export class ReadUserBlocks {
  constructor(private readonly repository:UserBlockRepository) {}
  execute(before:string|null=null) { if (before!==null && !blockId(before)) throw new BlockFailure('invalid');return this.repository.list(before); }
}
export class PrepareUserBlock {
  constructor(private readonly repository:UserBlockRepository) {}
  execute(target:BlockTarget) { if (!target || !['lost','found','sighting'].includes(target.kind) || !blockId(target.id)) throw new BlockFailure('invalid');return this.repository.prepare(target); }
}
export class SetUserBlock {
  constructor(private readonly repository:UserBlockRepository) {}
  execute(change:BlockChange) { if (!change?.entry || !blockId(change.entry.id) || typeof change.enabled!=='boolean' || !Number.isInteger(change.entry.version) || change.entry.version<0 || change.entry.version>=2147483647) throw new BlockFailure('invalid');return this.repository.set(change); }
}
