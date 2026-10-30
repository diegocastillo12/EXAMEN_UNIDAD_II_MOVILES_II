import { deliver, FcmSender } from "./delivery.ts";
import type { Delivery, DeliveryStore, ServiceAccount } from "./delivery.ts";

const json = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json", "Cache-Control": "no-store" } });
async function authorized(provided: string, expected: string) {
  const digest = async (s: string) => new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s)));
  const [a, b] = await Promise.all([digest(provided), digest(`Bearer ${expected}`)]);
  let mismatch = 0; for (let i = 0; i < a.length; i++) mismatch |= a[i] ^ b[i];
  return expected.length >= 32 && mismatch === 0;
}
export function createHandler(env: (name: string) => string | undefined, requestFetch: typeof fetch = fetch) {
return async function handler(request: Request) {
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });
  if (!await authorized(request.headers.get("Authorization") ?? "", env("NOTIFICATION_WORKER_SECRET") ?? "")) return json(403, { error: "forbidden" });
  try {
    const url = env("SUPABASE_URL");
    const key = env("SUPABASE_SERVICE_ROLE_KEY");
    const account = JSON.parse(env("FCM_SERVICE_ACCOUNT_JSON") ?? "null") as ServiceAccount | null;
    if (!url || !key || !account?.private_key || !account.client_email || !account.project_id) return json(503, { error: "configuration" });
    const rpc = async (operation: string, parameters: unknown) => {
      const response = await requestFetch(`${url}/rest/v1/rpc/${operation}`, { method: "POST", signal: AbortSignal.timeout(10_000), headers: { apikey: key, Authorization: `Bearer ${key}`, "Content-Type": "application/json" }, body: JSON.stringify(parameters) });
      if (!response.ok) throw new Error("outbox_unavailable");
      const text = await response.text(); return text ? JSON.parse(text) : null;
    };
    const store: DeliveryStore = {
      claim: () => rpc("claim_notification_delivery", {}),
      finish: async (job: Delivery, success, error, invalid) => { await rpc("finish_notification_delivery", { p_id: job.id, p_lease: job.lease, p_success: success, p_error: error, p_invalid_tokens: invalid }); },
    };
    return json(200, await deliver(store, new FcmSender(account, requestFetch)));
  } catch { return json(503, { error: "delivery_unavailable" }); }
};
}
