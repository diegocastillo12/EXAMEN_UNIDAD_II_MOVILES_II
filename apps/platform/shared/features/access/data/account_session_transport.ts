import { accountSessionDto } from './account_session_dto.ts';
// Short-lived, per-browser-app transport reuse. Never persisted or serialized.
export class AccountSessionTransport {
  private generation = 0;
  private cached: { body: string; status: number; until: number } | null = null;
  private pending: Promise<{ body: string; status: number }> | null = null;
  constructor(private readonly fetcher: typeof fetch = (input, init) => globalThis.fetch(input, init), private readonly now = Date.now) {}
  invalidate() { ++this.generation; this.cached = null; this.pending = null; }
  preparedSession() {
    if (!this.cached || this.cached.status !== 200 || this.now() >= this.cached.until) return null;
    try { return accountSessionDto(JSON.parse(this.cached.body)); } catch { return null; }
  }
  fetch: typeof fetch = async (input, init) => {
    const path = String(input);
    const sessionRead = path === '/api/access/session' && (!init?.method || init.method === 'GET');
    if (!sessionRead) {
      const identityWrite = init?.method === 'POST' && /\/api\/(access|moderation)\/(login|logout|onboarding|oauth\/start|credentials\/[^/]+)$/.test(path);
      if (identityWrite) this.invalidate();
      try {
        const response = await this.fetcher(input, init);
        if ([401, 409].includes(response.status)) this.invalidate();
        return response;
      } finally { if (identityWrite) this.invalidate(); }
    }
    if (this.cached && this.now() < this.cached.until) return new Response(this.cached.body, { status: this.cached.status });
    if (this.pending) { const response = await this.pending; return new Response(response.body, { status: response.status }); }
    const generation = this.generation;
    const pending = (async () => {
      const response = await this.fetcher(input, init);
      const body = await response.text();
      if (generation !== this.generation) return { body: '{}', status: 409 };
      let until = 0;
      if (response.status === 200) {
        try { until = Math.min(this.now() + 15000, JSON.parse(body).expiresAt); } catch { /* Malformed responses are never reused. */ }
      } else if (response.status === 401) until = this.now() + 5000;
      if (Number.isFinite(until) && until > this.now()) this.cached = { body, status: response.status, until };
      return { body, status: response.status };
    })();
    this.pending = pending;
    try { const response = await pending; return new Response(response.body, { status: response.status }); }
    finally { if (this.pending === pending) this.pending = null; }
  };
}
