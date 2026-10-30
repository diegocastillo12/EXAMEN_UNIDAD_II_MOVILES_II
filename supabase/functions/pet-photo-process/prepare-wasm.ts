// Reproducible build prerequisite, no credentials or remote mutations.
import "@imagemagick/magick-wasm";
await Deno.mkdir(new URL("./assets/", import.meta.url), { recursive: true });
await Deno.copyFile(
  new URL("./x86/magick.wasm", import.meta.resolve("@imagemagick/magick-wasm")),
  new URL("./assets/magick.wasm", import.meta.url),
);
console.log("magick.wasm preparado desde la dependencia fijada en deno.lock.");
