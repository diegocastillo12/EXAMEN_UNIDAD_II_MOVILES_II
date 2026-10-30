export type AccessIssue = 'invalid' | 'unauthenticated' | 'forbidden' | 'conflict' | 'unavailable';
export class AccessFailure extends Error {
  constructor(readonly kind: AccessIssue) { super(kind); }
}
export type SocialProvider = 'google' | 'facebook';
export function socialProvider(value: unknown): SocialProvider {
  if (value !== 'google' && value !== 'facebook') throw new AccessFailure('invalid');
  return value;
}
export type AccountSession = Readonly<{
  actor: string; expiresAt: number; email: string | null;
  profile: Readonly<{ displayName: string | null; city: string | null; onboardingCompleted: boolean }>;
}>;
export interface AccountRepository {
  session(): Promise<AccountSession>;
  login(email: string, password: string): Promise<AccountSession>;
  logout(): Promise<void>;
  completeOnboarding(): Promise<AccountSession>;
  canReviewReports(): Promise<boolean>;
}
export class AccessAccount {
  constructor(private readonly repository: AccountRepository) {}
  session() { return this.repository.session(); }
  login(email: string, password: string) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()) || email.length > 254 || !password || password.length > 1024) throw new AccessFailure('invalid');
    return this.repository.login(email.trim(), password);
  }
  logout() { return this.repository.logout(); }
}
export class CompleteAccountOnboarding {
  constructor(private readonly repository: AccountRepository) {}
  execute() { return this.repository.completeOnboarding(); }
}
export class ReadManagementAccess {
  constructor(private readonly repository: AccountRepository) {}
  execute() { return this.repository.canReviewReports(); }
}
export interface SocialSignInRepository { start(provider: SocialProvider): Promise<string>; }
export class StartAccountSocialSignIn {
  constructor(private readonly repository: SocialSignInRepository) {}
  execute(provider: SocialProvider) { return this.repository.start(socialProvider(provider)); }
}
export interface AccountSocialCodeRepository { exchange(code: string, verifier: string): Promise<AccountSession>; }
export class CompleteAccountSocialSignIn {
  constructor(private readonly repository: AccountSocialCodeRepository) {}
  execute(code: string, verifier: string) {
    if (!code || code.length > 2048 || !/^[A-Za-z0-9_-]{43,128}$/.test(verifier)) throw new AccessFailure('unauthenticated');
    return this.repository.exchange(code, verifier);
  }
}

