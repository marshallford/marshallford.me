#!/usr/bin/env sh
echo '{"region": "$REGION"}' | envsubst > /usr/share/nginx/html/config.json
