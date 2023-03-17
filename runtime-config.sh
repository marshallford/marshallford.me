#!/usr/bin/env sh
# shellcheck disable=SC2016
echo '{"region": "$REGION"}' | envsubst > /usr/share/nginx/html/config.json
