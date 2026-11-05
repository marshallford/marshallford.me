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

FROM docker.io/caddy:2.11.8-alpine@sha256:3db3a09e418f86a8fce8de4bc0026fccd2b4cd925aef00cc7d843d9fdc75e442

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/public /srv

ENV XDG_CONFIG_HOME=/tmp XDG_DATA_HOME=/tmp
USER 1000:1000
