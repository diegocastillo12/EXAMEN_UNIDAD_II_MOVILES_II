import { CredentialFailure } from '../domain/credentials.ts';
import type { CredentialProgress, CredentialResult } from '../domain/credentials.ts';
import { accountSessionDto } from './account_session_dto.ts';
export function credentialProgressDto(value: unknown): CredentialProgress | null {
  if (value === null) return null;
  const raw = value as Partial<CredentialProgress> | null;
  if (!raw || !['registration', 'recovery'].includes(String(raw.kind)) || !['code', 'reset'].includes(String(raw.stage)) ||
      (raw.stage === 'reset' && raw.kind !== 'recovery') || typeof raw.email !== 'string' || raw.email.length > 254 ||
      typeof raw.id !== 'string' || !/^[a-f0-9]{32}$/.test(raw.id) || !Number.isFinite(raw.retryAt) || !Number.isFinite(raw.expiresAt)) throw new CredentialFailure('unavailable');
  return Object.freeze({ kind: raw.kind!, stage: raw.stage!, email: raw.email, id: raw.id, retryAt: raw.retryAt!, expiresAt: raw.expiresAt! });
}
export function credentialResultDto(value: unknown): CredentialResult {
  const raw = value as { progress?: unknown; session?: unknown } | null;
  if (!raw) throw new CredentialFailure('unavailable');
  const progress = credentialProgressDto(raw.progress), session = raw.session === null ? null : accountSessionDto(raw.session);
  if ((!progress && !session) || (progress && session)) throw new CredentialFailure('unavailable');
  return Object.freeze({ progress, session });
}
