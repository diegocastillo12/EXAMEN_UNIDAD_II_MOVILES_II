import {
  ImageMagick,
  MagickColors,
  MagickFormat,
} from "@imagemagick/magick-wasm";
import { handlePhotoRequest } from "./index.ts";
function assert(value: unknown): asserts value {
  if (!value) throw new Error("assertion failed");
}
const owner = "11111111-1111-4111-8111-111111111130";
const pet = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaa30";
const id = "cccccccc-cccc-4ccc-8ccc-cccccccccc30";
const bytes = ImageMagick.read(
  MagickColors.Red,
  32,
  16,
  (image) => image.write(MagickFormat.Jpeg, (data) => Uint8Array.from(data)),
);
function request(
  content: Uint8Array = bytes,
  extra: Record<string, string> = {},
) {
  return new Request("https://example.invalid/photo", {
    method: "POST",
    body: Uint8Array.from(content),
    headers: {
      authorization: "Bearer fake-session",
      "content-type": "image/jpeg",
      "x-pet-id": pet,
      "x-photo-id": id,
      ...extra,
    },
  });
}
function fixture(
  options: {
    denied?: boolean;
    alienPet?: boolean;
    failStorage?: boolean;
    retireOnFailure?: boolean;
    failSecond?: boolean;
    found?: boolean;
  } = {},
) {
  const previous = globalThis.fetch;
  const savedEnv = new Map(
    ["SUPABASE_URL", "SUPABASE_ANON_KEY", "SUPABASE_SERVICE_ROLE_KEY"].map(
      (key) => [key, Deno.env.get(key)],
    ),
  );
  Deno.env.set("SUPABASE_URL", "https://example.supabase.co");
  Deno.env.set("SUPABASE_ANON_KEY", "fake-publishable");
  Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "fake-server-only");
  const calls: string[] = [];
  const uploaded = new Map<string, Uint8Array>();
  let published = false;
  let hash: string | undefined;
  const row = {
    id,
    ...(options.found ? { case_id: pet } : { pet_id: pet }),
    owner_id: owner,
    status: "pending",
    processed_at: null as string | null,
  };
  globalThis.fetch = async (input, init) => {
    const req = new Request(input, init), path = new URL(req.url).pathname;
    calls.push(path);
    let data: unknown, status = 200;
    if (path === "/auth/v1/user") {
      status = options.denied ? 401 : 200;
      data = options.denied ? { msg: "private detail" } : {
        id: owner,
        aud: "authenticated",
        app_metadata: {},
        user_metadata: {},
        created_at: "2026-10-10T00:00:00Z",
      };
    } else if (
      path === (options.found ? "/rest/v1/found_cases" : "/rest/v1/pets")
    ) {
      data = options.alienPet ? null : { id: pet };
    } else if (
      path ===
        (options.found
          ? "/rest/v1/rpc/prepare_found_case_photo"
          : "/rest/v1/rpc/prepare_pet_photo")
    ) {
      const command = await req.json();
      assert(
        command.p_owner === owner &&
          (options.found ? command.p_case_id : command.p_pet_id) === pet &&
          command.p_id === id,
      );
      assert(/^[0-9a-f]{64}$/.test(command.p_hash));
      if (
        (options.retireOnFailure && hash) || (hash && hash !== command.p_hash)
      ) {
        status = 400;
        data = { code: "40001", message: "photo_conflict" };
      } else {
        hash = command.p_hash;
        data = [
          published
            ? {
              ...row,
              status: options.found ? "ready" : "published",
              processed_at: "2026-10-10T00:00:00Z",
            }
            : row,
        ];
      }
    } else if (path.startsWith("/storage/v1/object/")) {
      if (req.method === "DELETE") {
        const { prefixes } = await req.json();
        for (const key of uploaded.keys()) {
          if (prefixes.some((prefix: string) => key.endsWith("/" + prefix))) {
            uploaded.delete(key);
          }
        }
        data = [];
      } else if (
        options.failStorage ||
        (options.failSecond && path.includes("thumbnails"))
      ) {
        status = 503;
        data = { error: "unavailable", message: "private detail" };
      } else {
        uploaded.set(path, new Uint8Array(await req.arrayBuffer()));
        data = { Key: path };
      }
    } else if (
      path ===
        (options.found
          ? "/rest/v1/rpc/complete_found_case_photo"
          : "/rest/v1/rpc/complete_pet_photo_processing")
    ) {
      const command = await req.json();
      assert(
        command.p_owner === owner && command.p_hash === hash &&
          uploaded.size === 2,
      );
      published = true;
      data = [{
        ...row,
        status: options.found ? "ready" : "published",
        processed_at: "2026-10-10T00:00:00Z",
        is_primary: true,
      }];
    } else throw new Error(`unexpected request ${path}`);
    return Response.json(data, { status });
  };
  return {
    calls,
    uploaded,
    dispose() {
      globalThis.fetch = previous;
      for (const [key, value] of savedEnv) {
        if (value === undefined) {
          Deno.env.delete(key);
        } else Deno.env.set(key, value);
      }
    },
  };
}
function foundRequest() {
  return new Request("https://example.invalid/photo", {
    method: "POST",
    body: bytes,
    headers: {
      authorization: "Bearer fake-session",
      "content-type": "image/jpeg",
      "x-found-case-id": pet,
      "x-photo-id": id,
    },
  });
}
Deno.test("Found photos authorize the reporter, use separate cleaned buckets and retry the same hash without a pet", async () => {
  const fake = fixture({ found: true });
  try {
    const response = await handlePhotoRequest(foundRequest());
    assert(response.status === 200);
    const data = await response.json();
    assert(
      data.status === "ready" && data.case_id === pet &&
        data.pet_id === undefined && data.content_hash === undefined,
    );
    assert(fake.uploaded.size === 2);
    assert([...fake.uploaded.keys()].every((p) => p.includes("/found-photo-")));
    assert(
      !fake.calls.some((p) =>
        p === "/rest/v1/pets" || p.includes("prepare_pet_photo")
      ),
    );
    const previous = fake.uploaded.size;
    assert((await handlePhotoRequest(foundRequest())).status === 200);
    assert(fake.uploaded.size === previous);
  } finally {
    fake.dispose();
  }
});
Deno.test("Found photos deny a different reporter before storage and reject mixed context headers", async () => {
  const fake = fixture({ found: true, alienPet: true });
  try {
    assert((await handlePhotoRequest(foundRequest())).status === 403);
    assert(
      (await handlePhotoRequest(request(bytes, { "x-found-case-id": pet })))
        .status === 422,
    );
    assert(
      !fake.calls.some((p) => p.includes("/rpc/") || p.includes("/storage/")),
    );
  } finally {
    fake.dispose();
  }
});
Deno.test("A failed found rendition never confirms processing", async () => {
  const fake = fixture({ found: true, failStorage: true });
  try {
    assert((await handlePhotoRequest(foundRequest())).status === 503);
    assert(!fake.calls.some((p) => p.includes("complete_found_case_photo")));
  } finally {
    fake.dispose();
  }
});
Deno.test("A discarded found photo cleans partial late bytes without publishing", async () => {
  const fake = fixture({
    found: true,
    failSecond: true,
    retireOnFailure: true,
  });
  try {
    assert((await handlePhotoRequest(foundRequest())).status === 503);
    assert(fake.uploaded.size === 0);
    assert(!fake.calls.some((p) => p.includes("complete_found_case_photo")));
    assert(
      fake.calls.some((p) => p === "/storage/v1/object/found-photo-renditions"),
    );
    assert(
      fake.calls.some((p) => p === "/storage/v1/object/found-photo-thumbnails"),
    );
  } finally {
    fake.dispose();
  }
});
Deno.test("Auth and ownership are checked before reserving or writing bytes", async () => {
  for (const option of [{ denied: true }, { alienPet: true }]) {
    const fake = fixture(option);
    try {
      const response = await handlePhotoRequest(request());
      assert(response.status === (option.denied ? 401 : 403));
      assert(
        !fake.calls.some((path) =>
          path.includes("/rpc/") || path.includes("/storage/")
        ),
      );
      assert(!JSON.stringify(await response.json()).includes("private detail"));
    } finally {
      fake.dispose();
    }
  }
});
Deno.test("Invalid files and bounded bodies never reserve a slot", async () => {
  const fake = fixture();
  try {
    for (
      const req of [
        request(new Uint8Array([1, 2, 3])),
        request(new Uint8Array(2097153)),
        request(bytes, { "content-type": "image/png" }),
        request(bytes, { "x-photo-id": "invalid" }),
      ]
    ) {
      assert((await handlePhotoRequest(req)).status === 422);
    }
    assert(
      !fake.calls.some((path) =>
        path.includes("/rpc/") || path.includes("/storage/")
      ),
    );
  } finally {
    fake.dispose();
  }
});
Deno.test("Upload publishes only both cleaned outputs; lost acknowledgements reuse immutable ID/hash", async () => {
  const fake = fixture();
  try {
    const first = await handlePhotoRequest(request());
    assert(first.status === 200);
    assert((await first.json()).status === "published");
    const before = fake.calls.filter((path) =>
      path.includes("/storage/")
    ).length;
    assert((await handlePhotoRequest(request())).status === 200);
    assert(
      fake.calls.filter((path) => path.includes("/storage/")).length === before,
    );
    const changed = bytes.slice();
    changed[changed.length - 3] ^= 1;
    // A competing command is rejected either as bad JPEG or incompatible hash.
    assert(
      [409, 422].includes((await handlePhotoRequest(request(changed))).status),
    );
  } finally {
    fake.dispose();
  }
});
Deno.test("Storage failure never confirms publication and exposes only a stable error", async () => {
  const fake = fixture({ failStorage: true });
  try {
    const response = await handlePhotoRequest(request());
    assert(response.status === 503);
    assert(
      !fake.calls.some((path) =>
        path.includes("complete_pet_photo_processing")
      ),
    );
    assert(
      JSON.stringify(await response.json()) === '{"error":"photo_failed"}',
    );
  } finally {
    fake.dispose();
  }
});
