import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
export type PrivateAccountSession = { actor: string; token: string; expiresAt: number };
const aad = Buffer.from('entrehuellas:account:v1');
export function sealAccountSession(session: PrivateAccountSession, secret: string): string {
  const iv = randomBytes(12), cipher = createCipheriv('aes-256-gcm', createHash('sha256').update(secret).digest(), iv);
  cipher.setAAD(aad);
  const bytes = Buffer.concat([cipher.update(JSON.stringify(session), 'utf8'), cipher.final()]);
  return Buffer.concat([iv, cipher.getAuthTag(), bytes]).toString('base64url');
}
export function openAccountSession(value: string | undefined, secret: string): PrivateAccountSession | null {
  try {
    if (!value || value.length > 6000) return null;
    const bytes = Buffer.from(value, 'base64url'), decipher = createDecipheriv('aes-256-gcm', createHash('sha256').update(secret).digest(), bytes.subarray(0, 12));
    decipher.setAAD(aad); decipher.setAuthTag(bytes.subarray(12, 28));
    const s = JSON.parse(Buffer.concat([decipher.update(bytes.subarray(28)), decipher.final()]).toString('utf8'));
    if (typeof s.actor !== 'string' || !/^[0-9a-f-]{36}$/.test(s.actor) || typeof s.token !== 'string' || s.token.length > 4096 ||
        !Number.isFinite(s.expiresAt) || s.expiresAt <= Date.now() || s.expiresAt > Date.now() + 3600001) return null;
    return { actor: s.actor, token: s.token, expiresAt: s.expiresAt };
  } catch { return null; }
}

