import { createRouter } from "./router.ts";

// API proporcionada por supabase/edge-runtime, no por Deno independiente.
declare const EdgeRuntime: {
  userWorkers: {
    create(options: {
      servicePath: string;
      staticPatterns: string[];
      memoryLimitMb: number;
      workerTimeoutMs: number;
      noModuleCache: boolean;
      importMapPath: string;
      envVars: [string, string][];
    }): Promise<{ fetch(request: Request): Promise<Response> }>;
  };
};

Deno.serve(createRouter(() =>
  EdgeRuntime.userWorkers.create({
    servicePath: "/home/deno/functions/pet-photo-process",
    // Edge Runtime compila en un FS virtual; copiar el WASM al volumen no basta.
    staticPatterns: [
      "/home/deno/functions/pet-photo-process/assets/magick.wasm",
    ],
    memoryLimitMb: 256,
    workerTimeoutMs: 60_000,
    noModuleCache: false,
    importMapPath: "/home/deno/functions/deno.json",
    envVars: [
      ["SUPABASE_URL", Deno.env.get("SUPABASE_URL") ?? ""],
      ["SUPABASE_ANON_KEY", Deno.env.get("SUPABASE_ANON_KEY") ?? ""],
      [
        "SUPABASE_SERVICE_ROLE_KEY",
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      ],
    ],
  })
));
