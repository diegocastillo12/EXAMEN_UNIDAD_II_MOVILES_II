import { ModerationFailure, uuid } from '../domain/moderation.ts';
import type { DecisionReceipt, ReportDetail, ReportPage, ReviewerSession } from '../domain/moderation.ts';
function row(raw: unknown): Record<string, unknown> { if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw new ModerationFailure('unavailable'); return raw as Record<string, unknown>; }
function text(raw: unknown): string { if (typeof raw !== 'string') throw new ModerationFailure('unavailable'); return raw; }
function id(raw: unknown): string { if (!uuid(raw)) throw new ModerationFailure('unavailable'); return raw; }
function number(raw: unknown): number { if (!Number.isSafeInteger(raw) || (raw as number) < 0) throw new ModerationFailure('unavailable'); return raw as number; }
function bool(raw: unknown): boolean { if (typeof raw !== 'boolean') throw new ModerationFailure('unavailable'); return raw; }
function time(raw: unknown): string { const value = text(raw); if (!Number.isFinite(Date.parse(value))) throw new ModerationFailure('unavailable'); return value; }
function kind(raw: unknown): string { const value = text(raw); if (!['lost','found','sighting'].includes(value)) throw new ModerationFailure('unavailable'); return value; }
export function sessionDto(raw: unknown): ReviewerSession {
  const r = row(raw), expiresAt = number(r.expiresAt);
  if (expiresAt <= Date.now()) throw new ModerationFailure('unauthenticated');
  return Object.freeze({ actor: id(r.actor), expiresAt });
}
export function decisionDto(raw: unknown): DecisionReceipt {
  const r = row(raw), action = text(r.action);
  if (!['hide','show','dismiss'].includes(action)) throw new ModerationFailure('unavailable');
  return Object.freeze({ id: id(r.command_id), report: id(r.report_id), actor: id(r.actor_id), action: action as DecisionReceipt['action'], reason: text(r.reason),
    reportVersion: number(r.report_version), resourceVersion: number(r.resource_version), hidden: bool(r.hidden), decidedAt: time(r.decided_at) });
}
export function pageDto(raw: unknown): ReportPage {
  const r = row(raw); if (!Array.isArray(r.items) || r.items.length > 20) throw new ModerationFailure('unavailable');
  const next = r.next == null ? null : row(r.next);
  return Object.freeze({ items: Object.freeze(r.items.map(value => { const i = row(value); return Object.freeze({ id: id(i.id), kind: kind(i.resource_kind), resourceId: id(i.resource_id), submittedAt: time(i.submitted_at), version: number(i.version) }); })),
    next: next ? Object.freeze({ time: time(next.time), id: id(next.id) }) : null });
}
export function detailDto(raw: unknown): ReportDetail {
  const d = row(raw), r = row(d.report), resource = d.resource == null ? null : row(d.resource);
  if (!Array.isArray(d.history) || d.history.length > 20) throw new ModerationFailure('unavailable');
  return Object.freeze({ id: id(r.id), kind: kind(r.resource_kind), resourceId: id(r.resource_id), submittedAt: time(r.submitted_at), reason: text(r.reason), evidence: r.evidence_note == null ? null : text(r.evidence_note),
    resource: resource ? Object.freeze({ title: text(resource.title), text: text(resource.text), status: text(resource.status), removed: bool(resource.removed), hasPhoto: bool(resource.has_photo) }) : null,
    reportVersion: number(d.report_version), resourceVersion: number(d.resource_version), hidden: bool(d.hidden), effectiveHidden: bool(d.effective_hidden), history: Object.freeze(d.history.map(decisionDto)) });
}
