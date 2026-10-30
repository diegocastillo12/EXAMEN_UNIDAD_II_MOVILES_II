FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN ONNXRUNTIME_NODE_INSTALL_CUDA=skip npm ci --include=dev --include=optional --ignore-scripts
COPY nuxt.config.ts tsconfig.json ./
COPY app app
COPY shared shared
COPY server server
COPY public public
COPY scripts/prepare-match-model.mjs scripts/prepare-match-model.mjs
COPY scripts/package-native-images.mjs scripts/package-native-images.mjs
RUN node scripts/prepare-match-model.mjs /app/models/clip-vit-b32-d15189d-q8-v1
RUN npm run build

FROM node:24-bookworm-slim AS runtime
WORKDIR /app
COPY --from=build /app/.output .output
COPY scripts/check-native-images.mjs scripts/check-native-images.mjs
COPY scripts/package-native-images.mjs scripts/package-native-images.mjs
# Fail the image build if Nitro omitted libvips or a native sharp dependency.
# This runs with only shipped dependencies, without the build's node_modules.
RUN node scripts/check-native-images.mjs
COPY --from=build --chown=node:node /app/models /app/models
COPY scripts/healthcheck.mjs scripts/healthcheck.mjs
USER node
ENV NODE_ENV=production HOST=0.0.0.0 PORT=5173 MATCH_MODEL_DIRECTORY=/app/models/clip-vit-b32-d15189d-q8-v1
EXPOSE 5173
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["node", "scripts/healthcheck.mjs"]
CMD ["node", ".output/server/index.mjs"]
