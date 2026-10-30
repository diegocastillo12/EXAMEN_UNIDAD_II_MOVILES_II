import { AppealFailure, isUuid } from '../domain/appeals.ts';
import type { AppealEntry, AppealPage, AppealCommand } from '../domain/appeals.ts';
function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new AppealFailure('unavailable');
  return value as Record<string, unknown>;
}
function string(value: unknown, max = 1000): string {
  if (typeof value !== 'string' || !value.trim() || [...value].length > max) throw new AppealFailure('unavailable');
  return value;
}
function id(value: unknown): string { if (!isUuid(value)) throw new AppealFailure('unavailable'); return value; }
function time(value: unknown): string { const s = string(value, 64); if (!Number.isFinite(Date.parse(s))) throw new AppealFailure('unavailable'); return s; }
export function appealDto(value: unknown): AppealEntry {
  const v = object(value), a = v.appeal === null ? null : object(v.appeal), b = a?.answer === null || !a ? null : object(a.answer);
  if (!['lost', 'found', 'sighting'].includes(v.kind as string) || !['hide', 'show', 'dismiss'].includes(v.action as string)) throw new AppealFailure('unavailable');
  return Object.freeze({ decision: id(v.decision), kind: v.kind as AppealEntry['kind'], resource: id(v.resource), action: v.action as AppealEntry['action'], reason: string(v.reason, 500), decidedAt: time(v.decidedAt),
    appeal: a ? Object.freeze({ id: id(a.id), reason: string(a.reason), submittedAt: time(a.submittedAt),
      answer: b ? Object.freeze({ id: id(b.id), actor: id(b.actor), reason: string(b.reason), answeredAt: time(b.answeredAt) }) : null }) : null });
}
export function appealPageDto(value: unknown): AppealPage {
  const v = object(value);
  if (!Array.isArray(v.items) || v.items.length > 20) throw new AppealFailure('unavailable');
  const next = v.next === null ? null : object(v.next);
  return Object.freeze({ items: Object.freeze(v.items.map(appealDto)), next: next ? Object.freeze({ time: time(next.time), id: id(next.id) }) : null });
}
export function appealReceiptDto(value: unknown, command: AppealCommand, answering = false): AppealEntry {
  const entry = appealDto(value), receipt = answering ? entry.appeal?.answer : entry.appeal;
  if (!receipt || receipt.id !== command.id || receipt.reason !== command.reason || (answering ? entry.appeal?.id : entry.decision) !== command.target) throw new AppealFailure('unavailable');
  return entry;
}
