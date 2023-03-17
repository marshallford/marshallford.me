FROM docker.io/node:18.15.0-bullseye as builder

ARG HUGO_RELEASE
RUN wget -q $HUGO_RELEASE -O hugo.tar.gz && tar -xzf hugo.tar.gz && cp hugo /usr/local/bin

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN hugo --minify --cleanDestinationDir --panicOnWarning

FROM docker.io/alpine/git:2.36.3 as h5bp-server-configs-nginx

WORKDIR /repo
RUN git config --global advice.detachedHead false && \
    git clone --depth 1 --branch 5.0.0 https://github.com/h5bp/server-configs-nginx.git .

FROM docker.io/nginxinc/nginx-unprivileged:1.23.3-alpine

USER root
RUN chown -R nginx /etc/nginx /usr/share/nginx
USER nginx

WORKDIR /etc/nginx
RUN rm -rf *
COPY --chown=nginx:nginx --from=h5bp-server-configs-nginx /repo/h5bp h5bp
COPY --chown=nginx:nginx --from=h5bp-server-configs-nginx /repo/conf.d/no-ssl.default.conf conf.d/
COPY --chown=nginx:nginx --from=h5bp-server-configs-nginx /repo/nginx.conf /repo/mime.types ./
RUN sed -i -e "s/user www-data;//g" -e "s/\/var\/run\/nginx.pid/\/tmp\/nginx.pid/g" nginx.conf
COPY --chown=nginx:nginx default.conf.template templates/
COPY --chown=nginx:nginx runtime-config.sh /docker-entrypoint.d/
COPY --chown=nginx:nginx --from=builder /app/public /usr/share/nginx/html

ENV NGINX_HOST=localhost
ENV PORT=8080
ENV REGION=local-container
