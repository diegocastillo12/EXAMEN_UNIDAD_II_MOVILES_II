import { registerHooks } from 'node:module';

// Only the production child process receives this preload. Its parent can still
// create the JPEG fixture using the development dependencies.
registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier === 'sharp' || specifier === '@huggingface/transformers') {
      throw new Error('Native image runtime unavailable (regression fixture)');
    }
    return nextResolve(specifier, context);
  },
});
