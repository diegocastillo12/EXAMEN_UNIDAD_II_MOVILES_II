import assert from "node:assert/strict";
import { test } from "node:test";
import { createHandler } from "./handler.ts";
test("Machine endpoint rejects GET, user JWTs and missing/short worker secrets before data access", async () => {
  for (const secret of [undefined, "short", "w".repeat(32)]) {
    let calls = 0;
    const handler = createHandler(name => name === "NOTIFICATION_WORKER_SECRET" ? secret : undefined, async () => { calls++; throw new Error("not allowed"); });
    assert.equal((await handler(new Request("https://example.test"))).status, 405);
    assert.equal((await handler(new Request("https://example.test", { method: "POST", headers: { Authorization: "Bearer user-jwt" } }))).status, 403);
    assert.equal(calls, 0);
  }
});
test("Authenticated dispatch only claims committed outbox via service RPC and returns safe counters", async () => {
  const env: Record<string,string> = { NOTIFICATION_WORKER_SECRET: "w".repeat(32), SUPABASE_URL: "https://example.test", SUPABASE_SERVICE_ROLE_KEY: "private-key", FCM_SERVICE_ACCOUNT_JSON: JSON.stringify({ private_key: "test", client_email: "sender@example.test", project_id: "project" }) };
  const handler = createHandler(name => env[name], async (url, init) => {
    assert.equal(String(url), "https://example.test/rest/v1/rpc/claim_notification_delivery");
    assert.equal((init!.headers as Record<string,string>).apikey, "private-key");
    return Response.json(null);
  });
  const response = await handler(new Request("https://worker.test", { method: "POST", headers: { Authorization: `Bearer ${env.NOTIFICATION_WORKER_SECRET}` } }));
  assert.equal(response.status, 200);assert.deepEqual(await response.json(), { sent: 0, retry: 0, skipped: 0 });
  delete env.FCM_SERVICE_ACCOUNT_JSON;
  const missing=await handler(new Request("https://worker.test", { method: "POST", headers: { Authorization: `Bearer ${env.NOTIFICATION_WORKER_SECRET}` } }));
  assert.equal(missing.status,503);assert.deepEqual(await missing.json(),{error:'configuration'});
});
