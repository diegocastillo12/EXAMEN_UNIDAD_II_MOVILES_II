import { createRouter } from "./router.ts";

function assert(value: unknown): asserts value {
  if (!value) throw new Error("assertion failed");
}
Deno.test("router rejects unknown routes and missing sessions before worker creation", async () => {
  let creations = 0;
  const router = createRouter(async () => {
    creations++;
    return { fetch: async () => new Response() };
  });
  assert((await router(new Request("http://functions/other"))).status === 404);
  assert(
    (await router(new Request("http://functions/pet-photo-process"))).status ===
      401,
  );
  assert(creations === 0);
});
Deno.test("router forwards original session, body and worker rejection", async () => {
  const router = createRouter(async () => ({
    fetch: async (request) => {
      assert(request.headers.get("authorization") === "Bearer user-session");
      assert(await request.text() === "photo-bytes");
      return Response.json({ code: "unauthorized" }, { status: 401 });
    },
  }));
  const response = await router(
    new Request("http://functions/pet-photo-process", {
      method: "POST",
      body: "photo-bytes",
      headers: { authorization: "Bearer user-session" },
    }),
  );
  assert(response.status === 401);
});
Deno.test("router allows preflight and normalizes worker boot failures", async () => {
  const preflight = createRouter(async () => ({
    fetch: async () => new Response(null, { status: 204 }),
  }));
  assert(
    (await preflight(
      new Request("http://functions/pet-photo-process", { method: "OPTIONS" }),
    )).status === 204,
  );
  const failing = createRouter(async () => {
    throw new Error("private SDK detail");
  });
  const response = await failing(
    new Request("http://functions/pet-photo-process", {
      headers: { authorization: "Bearer user-session" },
    }),
  );
  assert(response.status === 503);
  assert(!JSON.stringify(await response.json()).includes("private SDK detail"));
});
