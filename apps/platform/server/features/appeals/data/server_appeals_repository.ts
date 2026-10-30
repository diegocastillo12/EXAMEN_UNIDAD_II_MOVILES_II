import type { AppealsRepository, AppealCommand, AppealCursor } from '../../../../shared/features/appeals/domain/appeals.ts';
import { appealReceiptDto, appealPageDto } from '../../../../shared/features/appeals/data/appeals_dto.ts';
import { AppealsSource } from './appeals_source.ts';
export class ServerAppealsRepository implements AppealsRepository {
  constructor(private readonly source: AppealsSource) {}
  async list(review: boolean, cursor: AppealCursor | null) { return appealPageDto(await this.source.rpc('list_moderation_appeals', { p_review: review, p_before_time: cursor?.time ?? null, p_before_id: cursor?.id ?? null })); }
  async submit(c: AppealCommand) { return appealReceiptDto(await this.source.rpc('submit_moderation_appeal', { p_id: c.id, p_decision: c.target, p_reason: c.reason }), c); }
  async answer(c: AppealCommand) { return appealReceiptDto(await this.source.rpc('answer_moderation_appeal', { p_id: c.id, p_appeal: c.target, p_reason: c.reason }), c, true); }
}
