import assert from "node:assert/strict";
import { test } from "node:test";
import { deliver, FcmSender } from "./delivery.ts";
import type { Delivery, DeliveryStore, SendResult } from "./delivery.ts";
const job: Delivery = { id: "42", lease: "lease", tokens: ["one", "two"], title: "Not included in payload" };
test("Provider failure persists retry and never creates another notification", async () => {
  const finished: unknown[] = []; let count = 0;
  const store: DeliveryStore = { claim: async () => count++ === 0 ? job : null, finish: async (...args) => { finished.push(args); } };
  const result = await deliver(store, { send: async () => { throw new Error("secret provider body"); } });
  assert.equal(result.retry, 1); assert.deepEqual(finished, [[job, false, "provider_unavailable", []]]);
});
test("Invalid tokens are retired; mixed delivery failures retry; success marks provider acceptance", async () => {
  for (const second of ["invalid", "sent", "retry"] as SendResult[]) {
    const finished: unknown[] = []; let count = 0;
    const store: DeliveryStore = { claim: async () => count++ === 0 ? job : null, finish: async (...args) => { finished.push(args); } };
    await deliver(store, { send: async (token) => token === "one" ? "invalid" : second });
    const success = second === "sent";
    assert.deepEqual(finished, [[job, success, second === "retry" ? "provider_unavailable" : success ? null : "invalid_device", second === "invalid" ? ["one", "two"] : ["one"]]]);
  }
});
test("Cancelled jobs never call the provider and bounded dispatch exits", async () => {
  const result = await deliver({ claim: async () => ({ skipped: true }), finish: async () => assert.fail() }, { send: async () => { assert.fail(); return "retry"; } }, 3);
  assert.equal(result.skipped, 3);
});
test("FCM uses server OAuth and account-neutral payload, handles invalid tokens and caches authentication", async () => {
  const pair = await crypto.subtle.generateKey({ name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" }, true, ["sign", "verify"]);
  const pkcs8 = await crypto.subtle.exportKey("pkcs8", pair.privateKey);
  const private_key = `-----BEGIN PRIVATE KEY-----\n${Buffer.from(pkcs8).toString("base64")}\n-----END PRIVATE KEY-----`;
  let oauth = 0, fcm = 0; const payloads: unknown[] = [];
  const sender = new FcmSender({ client_email: "sender@example.test", project_id: "test-project", private_key }, async (input, init) => {
    if (String(input).includes("oauth2")) {
      oauth++; const assertion = (init!.body as URLSearchParams).get("assertion")!;
      const [header, body, signature] = assertion.split(".");
      assert.equal(await crypto.subtle.verify("RSASSA-PKCS1-v1_5", pair.publicKey, Buffer.from(signature, "base64url"), new TextEncoder().encode(`${header}.${body}`)), true);
      assert.equal(JSON.parse(Buffer.from(body, "base64url").toString()).scope, "https://www.googleapis.com/auth/firebase.messaging");
      return Response.json({ access_token: "server-token", expires_in: 3600 });
    }
    fcm++; assert.equal((init!.headers as Record<string, string>).Authorization, "Bearer server-token");
    payloads.push(JSON.parse(init!.body as string));
    return fcm === 1 ? Response.json({ name: "accepted" }) : Response.json({ error: { details: [{ errorCode: "UNREGISTERED" }] } }, { status: 404 });
  });
  assert.equal(await sender.send("device-token", "42"), "sent");
  assert.equal(await sender.send("device-token", "42"), "invalid");
  assert.equal(oauth, 1);
  const payload = JSON.stringify(payloads);
  for (const forbidden of ["latitude", "case_id", "private_key", "sender@example", "Not included"]) assert.ok(!payload.includes(forbidden));
  assert.ok(payload.includes('"tag":"eh-42"'));assert.ok(payload.includes('"ttl":"60s"'));
});
