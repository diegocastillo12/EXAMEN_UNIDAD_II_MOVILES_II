export type Delivery = { id: string; lease: string; tokens: string[]; title: string };
export type SendResult = "sent" | "invalid" | "retry";
export interface DeliveryStore {
  claim(): Promise<Delivery | { skipped: true } | null>;
  finish(job: Delivery, success: boolean, error: string | null, invalid: string[]): Promise<void>;
}
export interface PushSender { send(token: string, id: string): Promise<SendResult> }

// The inbox/job is committed before this worker sees it. Provider acceptance is not delivery.
export async function deliver(store: DeliveryStore, sender: PushSender, limit = 3) {
  const summary = { sent: 0, retry: 0, skipped: 0 };
  for (let i = 0; i < limit; i++) {
    const job = await store.claim();
    if (!job) break;
    if ("skipped" in job) { summary.skipped++; continue; }
    const results = await Promise.all(job.tokens.map(async token => {
      try { return { token, result: await sender.send(token, job.id) }; }
      catch { return { token, result: "retry" as const }; }
    }));
    const retry = results.some(r => r.result === "retry");
    const success = !retry && results.some(r => r.result === "sent");
    await store.finish(job, success, retry ? "provider_unavailable" : success ? null : "invalid_device", results.filter(r => r.result === "invalid").map(r => r.token));
    if (success) summary.sent++; else summary.retry++;
  }
  return summary;
}

const base64url = (bytes: Uint8Array) => btoa(String.fromCharCode(...bytes)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
const encode = (value: unknown) => base64url(new TextEncoder().encode(JSON.stringify(value)));
export type ServiceAccount = { client_email: string; private_key: string; project_id: string };
export class FcmSender implements PushSender {
  private access?: { token: string; expires: number };
  constructor(private account: ServiceAccount, private request: typeof fetch = fetch) {}
  private async token() {
    if (this.access && this.access.expires > Date.now() + 60_000) return this.access.token;
    const now = Math.floor(Date.now() / 1000);
    const unsigned = `${encode({ alg: "RS256", typ: "JWT" })}.${encode({ iss: this.account.client_email, scope: "https://www.googleapis.com/auth/firebase.messaging", aud: "https://oauth2.googleapis.com/token", iat: now, exp: now + 3600 })}`;
    const pem = this.account.private_key.replace(/-----[^-]+-----/g, "").replace(/\s/g, "");
    const key = await crypto.subtle.importKey("pkcs8", Uint8Array.from(atob(pem), c => c.charCodeAt(0)), { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"]);
    const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned));
    const response = await this.request("https://oauth2.googleapis.com/token", { method: "POST", signal: AbortSignal.timeout(10_000), body: new URLSearchParams({ grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: `${unsigned}.${base64url(new Uint8Array(signature))}` }) });
    if (!response.ok) throw new Error("fcm_auth_unavailable");
    const result = await response.json();
    if (typeof result.access_token !== "string" || !Number.isFinite(result.expires_in)) throw new Error("fcm_auth_unavailable");
    this.access = { token: result.access_token, expires: Date.now() + result.expires_in * 1000 };
    return this.access.token;
  }
  async send(token: string, id: string): Promise<SendResult> {
    const access = await this.token();
    const response = await this.request(`https://fcm.googleapis.com/v1/projects/${encodeURIComponent(this.account.project_id)}/messages:send`, {
      method: "POST", signal: AbortSignal.timeout(10_000), headers: { Authorization: `Bearer ${access}`, "Content-Type": "application/json" },
      // Generic and account-neutral on lock screens. No case IDs, location or evidence.
      body: JSON.stringify({ message: { token, notification: { title: "Entre Huellas", body: "Tienes novedades. Abre tu bandeja de alertas." }, data: { destination: "inbox" }, android: { ttl: "60s", notification: { tag: `eh-${id}` } } } }),
    });
    if (response.ok) return "sent";
    if (response.status === 401) this.access = undefined;
    let body: { error?: { details?: Array<{ errorCode?: string }> } } = {};
    try { body = await response.json(); } catch { /* Retry without storing provider messages. */ }
    return body.error?.details?.some(d => d.errorCode === "UNREGISTERED") ? "invalid" : "retry";
  }
}
