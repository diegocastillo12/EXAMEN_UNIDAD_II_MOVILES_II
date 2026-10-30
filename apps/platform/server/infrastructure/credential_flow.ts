import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import type { CredentialKind, CredentialProgress } from '../../shared/features/access/domain/credentials.ts';
import type { PrivateAccountSession } from './account_session.ts';
export type PrivateCredentialFlow = { id: string; kind: CredentialKind; email: string; retryAt: number; expiresAt: number; recovery: PrivateAccountSession | null };
const aad = Buffer.from('entrehuellas:credential-flow:v1');
export const credentialCookie = 'eh_credentials';
export function newCredentialFlow(kind: CredentialKind, email: string): PrivateCredentialFlow {
  return { id: randomBytes(16).toString('hex'), kind, email, retryAt: Date.now() + 60000, expiresAt: Date.now() + 1800000, recovery: null };
}
export function publicCredentialFlow(flow: PrivateCredentialFlow): CredentialProgress {
  return { id: flow.id, kind: flow.kind, stage: flow.recovery ? 'reset' : 'code', email: flow.email, retryAt: flow.retryAt, expiresAt: flow.expiresAt };
}
export function sealCredentialFlow(flow: PrivateCredentialFlow, secret: string) {
  const iv = randomBytes(12), cipher = createCipheriv('aes-256-gcm', createHash('sha256').update(secret).digest(), iv);
  cipher.setAAD(aad);
  const bytes = Buffer.concat([cipher.update(JSON.stringify(flow), 'utf8'), cipher.final()]);
  return Buffer.concat([iv, cipher.getAuthTag(), bytes]).toString('base64url');
}
export function openCredentialFlow(value: string | undefined, secret: string): PrivateCredentialFlow | null {
  try {
    if (!value || value.length > 6000) return null;
    const raw = Buffer.from(value, 'base64url'), decipher = createDecipheriv('aes-256-gcm', createHash('sha256').update(secret).digest(), raw.subarray(0, 12));
    decipher.setAAD(aad); decipher.setAuthTag(raw.subarray(12, 28));
    const flow = JSON.parse(Buffer.concat([decipher.update(raw.subarray(28)), decipher.final()]).toString('utf8'));
    if (!/^[a-f0-9]{32}$/.test(flow.id) || !['registration', 'recovery'].includes(flow.kind) || typeof flow.email !== 'string' || flow.email.length > 254 ||
        !Number.isFinite(flow.retryAt) || !Number.isFinite(flow.expiresAt) || flow.expiresAt <= Date.now() || flow.expiresAt > Date.now() + 1800001) return null;
    if (flow.recovery !== null && (flow.kind !== 'recovery' || typeof flow.recovery.actor !== 'string' || !/^[0-9a-f-]{36}$/.test(flow.recovery.actor) ||
        typeof flow.recovery.token !== 'string' || !flow.recovery.token || flow.recovery.token.length > 4096 || !Number.isFinite(flow.recovery.expiresAt) || flow.recovery.expiresAt <= Date.now())) return null;
    return flow as PrivateCredentialFlow;
  } catch { return null; }
}
