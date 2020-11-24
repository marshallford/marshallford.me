FROM node:14.15.1-buster as builder

ARG HUGO_RELEASE

WORKDIR /tmp
ADD ${HUGO_RELEASE} hugo.tar.gz
RUN tar -xzf hugo.tar.gz && cp hugo /usr/local/bin

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN hugo --minify --cleanDestinationDir

FROM nginxinc/nginx-unprivileged:1.18.0-alpine

ARG MAINTAINER
ARG CREATED
ARG REVISION
ARG VERSION
ARG TITLE
ARG REPOSITORY_URL

LABEL maintainer=$MAINTAINER
LABEL org.opencontainers.image.created=$CREATED \
      org.opencontainers.image.revision=$REVISION \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.title=$TITLE \
      org.opencontainers.image.source=$REPOSITORY_URL \
      org.opencontainers.image.url=$REPOSITORY_URL

COPY --from=builder /app/public /usr/share/nginx/html
