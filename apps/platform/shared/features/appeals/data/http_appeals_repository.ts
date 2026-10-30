import { AppealFailure } from '../domain/appeals.ts';
import type { AppealsRepository, AppealCommand, AppealCursor } from '../domain/appeals.ts';
import { appealReceiptDto, appealPageDto } from './appeals_dto.ts';
export class HttpAppealsRepository implements AppealsRepository {
  constructor(private readonly actor: string, private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init)) {}
  private async call(operation: string, body: unknown) {
    try {
      const response = await this.fetcher('/api/appeals/' + operation, { method: 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { 'X-Account-Actor': this.actor, 'Content-Type': 'application/json' }, body: JSON.stringify(body), signal: AbortSignal.timeout(30000) });
      if (!response.ok) { await response.body?.cancel(); throw new AppealFailure(response.status === 401 ? 'unauthenticated' : response.status === 403 ? 'forbidden' : response.status === 409 ? 'conflict' : response.status === 422 ? 'invalid' : 'unavailable'); }
      return await response.json();
    } catch (error) { throw error instanceof AppealFailure ? error : new AppealFailure('unavailable'); }
  }
  async list(review: boolean, cursor: AppealCursor | null) { return appealPageDto(await this.call('list', { review, cursor })); }
  async submit(command: AppealCommand) { return appealReceiptDto(await this.call('submit', command), command); }
  async answer(command: AppealCommand) { return appealReceiptDto(await this.call('answer', command), command, true); }
}
