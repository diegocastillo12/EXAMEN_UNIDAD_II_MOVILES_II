export type AppealIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable';
export class AppealFailure extends Error {
  constructor(readonly kind: AppealIssue) { super(kind); }
}
export type AppealCursor = Readonly<{ time: string; id: string }>;
export type AppealEntry = Readonly<{
  decision: string; kind: 'lost' | 'found' | 'sighting'; resource: string;
  action: 'hide' | 'show' | 'dismiss'; reason: string; decidedAt: string;
  appeal: Readonly<{ id: string; reason: string; submittedAt: string;
    answer: Readonly<{ id: string; actor: string; reason: string; answeredAt: string }> | null }> | null;
}>;
export type AppealPage = Readonly<{ items: readonly AppealEntry[]; next: AppealCursor | null }>;
export type AppealCommand = Readonly<{ id: string; target: string; reason: string }>;
export interface AppealsRepository {
  list(review: boolean, cursor: AppealCursor | null): Promise<AppealPage>;
  submit(command: AppealCommand): Promise<AppealEntry>;
  answer(command: AppealCommand): Promise<AppealEntry>;
}
export function isUuid(value: unknown): value is string {
  return typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(value);
}
export class ReadAppeals {
  constructor(private readonly repository: AppealsRepository) {}
  execute(review: boolean, cursor: AppealCursor | null = null) {
    if (typeof review !== 'boolean' || (cursor && (!isUuid(cursor.id) || !Number.isFinite(Date.parse(cursor.time))))) throw new AppealFailure('invalid');
    return this.repository.list(review, cursor);
  }
}
function validated(command: AppealCommand): AppealCommand {
  if (!isUuid(command.id) || !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab]/.test(command.id) || !isUuid(command.target) || typeof command.reason !== 'string' ||
    !command.reason.trim() || [...command.reason.trim()].length > 1000) throw new AppealFailure('invalid');
  return Object.freeze({ ...command, reason: command.reason.trim() });
}
export class SubmitAppeal {
  constructor(private readonly repository: AppealsRepository) {}
  execute(command: AppealCommand) { return this.repository.submit(validated(command)); }
}
export class AnswerAppeal {
  constructor(private readonly repository: AppealsRepository) {}
  execute(command: AppealCommand) { return this.repository.answer(validated(command)); }
}
