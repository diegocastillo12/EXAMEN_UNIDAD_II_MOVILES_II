import type { AccountSession } from './access.ts';

export type CredentialIssue = 'invalid_request' | 'invalid_name' | 'invalid_email' | 'weak_password' | 'password_mismatch' | 'invalid_code' | 'expired' | 'same_password' | 'rate_limited' | 'unavailable' | 'conflict';
export class CredentialFailure extends Error {
  constructor(readonly kind: CredentialIssue) { super(kind); }
}
export type CredentialKind = 'registration' | 'recovery';
export type CredentialProgress = Readonly<{ kind: CredentialKind; stage: 'code' | 'reset'; email: string; retryAt: number; expiresAt: number; id: string }>;
export type CredentialResult = Readonly<{ progress: CredentialProgress | null; session: AccountSession | null }>;
export interface CredentialRepository {
  progress(): Promise<CredentialProgress | null>;
  register(name: string, email: string, password: string): Promise<CredentialResult>;
  requestRecovery(email: string): Promise<CredentialProgress>;
  verify(kind: CredentialKind, id: string, code: string): Promise<CredentialResult>;
  resend(kind: CredentialKind, id: string): Promise<CredentialProgress>;
  resetAccess(): Promise<void>;
  reset(id: string, password: string): Promise<void>;
  cancel(): Promise<void>;
}
function emailAddress(value: string) {
  const email = value.trim();
  if (email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new CredentialFailure('invalid_email');
  return email;
}
function passwordPair(password: string, confirmation: string) {
  if (password.length < 8 || password.length > 1024) throw new CredentialFailure('weak_password');
  if (password !== confirmation) throw new CredentialFailure('password_mismatch');
}
function flowId(value: string) { if (!/^[a-f0-9]{32}$/.test(value)) throw new CredentialFailure('expired'); }
export class RegisterAccount {
  constructor(private readonly repository: CredentialRepository) {}
  execute(name: string, email: string, password: string, confirmation: string) {
    if (!name.trim() || name.trim().length > 120) throw new CredentialFailure('invalid_name');
    const normalized = emailAddress(email); passwordPair(password, confirmation);
    return this.repository.register(name.trim(), normalized, password);
  }
}
export class RequestPasswordRecovery {
  constructor(private readonly repository: CredentialRepository) {}
  execute(email: string) { return this.repository.requestRecovery(emailAddress(email)); }
}
export class VerifyAccountCode {
  constructor(private readonly repository: CredentialRepository) {}
  execute(kind: CredentialKind, id: string, code: string) {
    flowId(id);
    if (!/^\d{6}$/.test(code)) throw new CredentialFailure('invalid_code');
    return this.repository.verify(kind, id, code);
  }
}
export class ResendAccountCode {
  constructor(private readonly repository: CredentialRepository, private readonly now = Date.now) {}
  execute(progress: CredentialProgress) {
    flowId(progress.id);
    if (progress.expiresAt <= this.now()) throw new CredentialFailure('expired');
    if (progress.retryAt > this.now()) throw new CredentialFailure('rate_limited');
    return this.repository.resend(progress.kind, progress.id);
  }
}
export class ResetAccountPassword {
  constructor(private readonly repository: CredentialRepository) {}
  execute(id: string, password: string, confirmation: string) { flowId(id); passwordPair(password, confirmation); return this.repository.reset(id, password); }
}
export class ReadCredentialProgress {
  constructor(private readonly repository: CredentialRepository) {}
  execute() { return this.repository.progress(); }
  resetAccess() { return this.repository.resetAccess(); }
}
export class CancelCredentialFlow {
  constructor(private readonly repository: CredentialRepository) {}
  execute() { return this.repository.cancel(); }
}
