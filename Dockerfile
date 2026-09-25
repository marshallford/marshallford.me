FROM docker.io/node:24.21.0-bookworm-slim@sha256:0e0ff40c39bc087845bfb27465a0df4ea419520094bc35842ff83dd8cbe6f9b6 AS builder

WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY . .
ARG HUGO_PARAMS_COMMIT
RUN npx hugo --minify --cleanDestinationDir --panicOnWarning

RUN node scripts/precompress.mjs public

FROM docker.io/caddy:2.11.4-alpine@sha256:de23def33b17fb5d1290b0f6c2add1d70780e52341896c00a4c8a2a2fe9d355e

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/public /srv

ENV XDG_CONFIG_HOME=/tmp XDG_DATA_HOME=/tmp
USER 1000:1000
