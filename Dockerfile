FROM docker.io/node:24.22.2-bookworm-slim@sha256:01d566e8d94d8c619591d78652babfccd3c6992a3dffa9ed5ab39e11cf6c70e9 AS builder

WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY . .
ARG SOURCE_DATE_EPOCH
ARG HUGO_PARAMS_COMMIT
ENV HUGO_PARAMS_COMMITTIME=$SOURCE_DATE_EPOCH
RUN npx hugo --minify --cleanDestinationDir --panicOnWarning

RUN node scripts/precompress.mjs public

FROM docker.io/caddy:2.11.8-alpine@sha256:f6228111e5fafa1a5238258d0858e103f10599b8d1659a146e7726681a002bb9

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/public /srv

ENV XDG_CONFIG_HOME=/tmp XDG_DATA_HOME=/tmp
USER 1000:1000
