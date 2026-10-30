import { BlockFailure } from '../../../../shared/features/user_blocks/domain/user_blocks.ts';
import type { UserBlockRepository,BlockTarget,BlockChange } from '../../../../shared/features/user_blocks/domain/user_blocks.ts';
import { blockEntry,blockPage } from '../../../../shared/features/user_blocks/data/user_block_dto.ts';
import { UserBlockSource } from './user_block_source.ts';
export class ServerUserBlockRepository implements UserBlockRepository {
  constructor(private readonly source:UserBlockSource) {}
  async list(before:string|null) {return blockPage(await this.source.rpc('list_user_blocks',{p_before:before}));}
  async prepare(target:BlockTarget) {const raw=await this.source.rpc('prepare_user_block',{p_kind:target.kind,p_resource:target.id});return raw===null?null:blockEntry(raw);}
  async set(change:BlockChange) {
    const result=blockEntry(await this.source.rpc('set_user_block',{p_id:change.entry.id,p_enabled:change.enabled,p_version:change.entry.version}));
    if(result.id!==change.entry.id || result.enabled!==change.enabled || result.version<change.entry.version || result.version>change.entry.version+1)throw new BlockFailure('unavailable');
    return result;
  }
}
