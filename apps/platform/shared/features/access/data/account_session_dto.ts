import { AccessFailure } from '../domain/access.ts';
import type { AccountSession } from '../domain/access.ts';
export function accountSessionDto(value: unknown): AccountSession {
  const s = value as AccountSession | null;
  const optional = (v: unknown, max: number) => v === null || (typeof v === 'string' && [...v].length <= max);
  if (!s || typeof s.actor !== 'string' || !/^[0-9a-f-]{36}$/.test(s.actor) ||
      !Number.isFinite(s.expiresAt) || s.expiresAt <= Date.now() || !optional(s.email, 320) ||
      !s.profile || !optional(s.profile.displayName, 120) || !optional(s.profile.city, 120) ||
      typeof s.profile.onboardingCompleted !== 'boolean') throw new AccessFailure('unavailable');
  return Object.freeze({ actor: s.actor, expiresAt: s.expiresAt, email: s.email, profile: Object.freeze({
    displayName: s.profile.displayName, city: s.profile.city, onboardingCompleted: s.profile.onboardingCompleted,
  }) });
}

