FROM docker.io/node:24.21.0-bookworm-slim@sha256:0e0ff40c39bc087845bfb27465a0df4ea419520094bc35842ff83dd8cbe6f9b6 AS builder

WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY . .
ARG SOURCE_DATE_EPOCH
ARG HUGO_PARAMS_COMMIT
ENV HUGO_PARAMS_COMMITTIME=$SOURCE_DATE_EPOCH
RUN npx hugo --minify --cleanDestinationDir --panicOnWarning

RUN node scripts/precompress.mjs public

FROM docker.io/caddy:2.11.4-alpine@sha256:6aeddd44c3078b0f9a35206472a11420648a79c184603ef95957d0a20044cb2b

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/public /srv

ENV XDG_CONFIG_HOME=/tmp XDG_DATA_HOME=/tmp
USER 1000:1000
