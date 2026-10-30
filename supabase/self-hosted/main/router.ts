export interface FunctionWorker {
  fetch(request: Request): Promise<Response>;
}
export type CreatePhotoWorker = () => Promise<FunctionWorker>;

// Kong elimina /functions/v1/. Solo esta función tiene acceso al entorno.
// La comprobación autoritativa de sesión y propietario permanece en el handler.
export function createRouter(createWorker: CreatePhotoWorker) {
  return async (request: Request): Promise<Response> => {
    const path = new URL(request.url).pathname;
    if (path !== "/pet-photo-process" && path !== "/pet-photo-process/") {
      return Response.json({ code: "not_found" }, { status: 404 });
    }
    if (
      request.method !== "OPTIONS" &&
      !/^Bearer\s+\S+$/i.test(request.headers.get("authorization") ?? "")
    ) {
      return Response.json({ code: "unauthorized" }, { status: 401 });
    }
    try {
      const worker = await createWorker();
      return await worker.fetch(request);
    } catch {
      console.error(
        "pet-photo-process: fallo de arranque o ejecución del worker",
      );
      return Response.json({ code: "processing_unavailable" }, { status: 503 });
    }
  };
}
