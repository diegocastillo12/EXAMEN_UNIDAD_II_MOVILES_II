import { CredentialFailure } from '../../../../shared/features/access/domain/credentials.ts';
import type { AccountConfig } from './account_source.ts';

// Only public Auth operations with a publishable key; never admin/user creation.
export class CredentialSource {
  constructor(private readonly config: AccountConfig, private readonly fetcher: typeof fetch = fetch) {}
  private async request(path: string, body?: unknown, token?: string, method = 'POST'): Promise<unknown> {
    try {
      const response = await this.fetcher(this.config.url + '/auth/v1/' + path, {
        method, headers: { apikey: this.config.key, ...(token ? { Authorization: 'Bearer ' + token } : {}), ...(body === undefined ? {} : { 'Content-Type': 'application/json' }) },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }), cache: 'no-store', redirect: 'error', signal: AbortSignal.timeout(12000),
      });
      const reader = response.body?.getReader(); const chunks: Uint8Array[] = []; let size = 0;
      if (reader) try { while (true) { const next = await reader.read(); if (next.done) break; size += next.value.length; if (size > 65536) throw new CredentialFailure('unavailable'); chunks.push(next.value); } } finally { await reader.cancel().catch(() => {}); }
      const text = Buffer.concat(chunks).toString('utf8');
      let raw: unknown = null; try { raw = text ? JSON.parse(text) : null; } catch { throw new CredentialFailure('unavailable'); }
      if (!response.ok) {
        const code = (raw as { code?: unknown; error_code?: unknown } | null)?.code || (raw as { error_code?: unknown } | null)?.error_code;
        if (path === 'signup' && ['user_already_exists', 'email_exists'].includes(String(code))) return { id: 'pending' };
        const kind = response.status === 429 || ['over_email_send_rate_limit', 'over_request_rate_limit'].includes(String(code)) ? 'rate_limited' : code === 'weak_password' ? 'weak_password' : code === 'same_password' ? 'same_password' :
          code === 'email_address_invalid' ? 'invalid_email' : path === 'verify' && ['otp_expired', 'otp_disabled', 'access_denied'].includes(String(code)) ? 'invalid_code' :
          response.status === 401 || ['session_not_found', 'refresh_token_not_found', 'bad_jwt', 'user_not_found', 'access_denied'].includes(String(code)) ? 'expired' : 'unavailable';
        throw new CredentialFailure(kind);
      }
      return raw;
    } catch (error) { throw error instanceof CredentialFailure ? error : new CredentialFailure('unavailable'); }
  }
  register(name: string, email: string, password: string) { return this.request('signup', { email, password, data: { full_name: name } }); }
  recover(email: string) { return this.request('recover', { email }); }
  resend(email: string) { return this.request('resend', { type: 'signup', email }); }
  verify(email: string, code: string, recovery: boolean) { return this.request('verify', { email, token: code, type: recovery ? 'recovery' : 'email' }); }
  user(token: string) { return this.request('user', undefined, token, 'GET'); }
  update(token: string, password: string) { return this.request('user', { password }, token, 'PUT'); }
}
