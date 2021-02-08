#!/bin/sh
set -e

export KONG_NGINX_DAEMON=off

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}
  mkdir -p $PREFIX

  if [[ "$2" == "docker-start" ]]; then
    if [[ -n "$KONG_NGINX_CONF" ]]; then
      kong prepare -p $PREFIX --nginx-conf $KONG_NGINX_CONF
    else
      kong prepare -p $PREFIX
    fi

    exec /usr/local/openresty/nginx/sbin/nginx \
      -p $PREFIX \
      -c nginx.conf
  fi
fi

exec "$@"
