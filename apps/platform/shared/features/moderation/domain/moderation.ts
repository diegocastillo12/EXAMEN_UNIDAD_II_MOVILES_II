export type ModerationIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable';
export class ModerationFailure extends Error {
  constructor(readonly kind: ModerationIssue) { super(kind); }
}
export type ReviewerSession = Readonly<{ actor: string; expiresAt: number }>;
export type QueueCursor = Readonly<{ time: string; id: string }>;
export type ReportRow = Readonly<{ id: string; kind: string; resourceId: string; submittedAt: string; version: number }>;
export type ReportPage = Readonly<{ items: readonly ReportRow[]; next: QueueCursor | null }>;
export type ModerationAction = 'hide' | 'show' | 'dismiss';
export type ModerationCommand = Readonly<{ id: string; report: string; reportVersion: number; resourceVersion: number; action: ModerationAction; reason: string }>;
export type DecisionReceipt = Readonly<{ id: string; report: string; actor: string; action: ModerationAction; reason: string; reportVersion: number; resourceVersion: number; hidden: boolean; decidedAt: string }>;
export type ReportDetail = Readonly<{
  id: string; kind: string; resourceId: string; submittedAt: string; reason: string; evidence: string | null;
  resource: Readonly<{ title: string; text: string; status: string; removed: boolean; hasPhoto: boolean }> | null;
  reportVersion: number; resourceVersion: number; hidden: boolean; effectiveHidden: boolean; history: readonly DecisionReceipt[];
}>;
export interface ModerationRepository {
  session(): Promise<ReviewerSession>;
  login(email: string, password: string): Promise<ReviewerSession>;
  logout(): Promise<void>;
  list(resolved: boolean, cursor: QueueCursor | null): Promise<ReportPage>;
  read(id: string): Promise<ReportDetail>;
  decide(command: ModerationCommand): Promise<DecisionReceipt>;
}
export class AccessModeration {
  constructor(private readonly repository: ModerationRepository) {}
  session() { return this.repository.session(); }
  login(email: string, password: string) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()) || email.length > 254 || !password || password.length > 1024) throw new ModerationFailure('invalid');
    return this.repository.login(email.trim(), password);
  }
  logout() { return this.repository.logout(); }
}
export class ReviewReports {
  constructor(private readonly repository: ModerationRepository) {}
  list(resolved: boolean, cursor: QueueCursor | null = null) { return this.repository.list(resolved, cursor); }
  read(id: string) { if (!uuid(id)) throw new ModerationFailure('invalid'); return this.repository.read(id); }
}
export function uuid(value: unknown): value is string { return typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(value); }
export class DecideReport {
  constructor(private readonly repository: ModerationRepository) {}
  execute(command: ModerationCommand) {
    if (!uuid(command.id) || command.id[14] !== '4' || !uuid(command.report) || !['hide','show','dismiss'].includes(command.action) ||
      !Number.isSafeInteger(command.reportVersion) || command.reportVersion < 0 || !Number.isSafeInteger(command.resourceVersion) || command.resourceVersion < 0 ||
      !command.reason.trim() || [...command.reason.trim()].length > 500) throw new ModerationFailure('invalid');
    return this.repository.decide(Object.freeze({ ...command, reason: command.reason.trim() }));
  }
}
