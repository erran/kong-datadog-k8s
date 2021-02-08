FROM kong:0.14.1-alpine

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD nginx-conf/custom_nginx.template /usr/local/kong/custom_nginx.template
ARG PLUGIN_ROCK_VERSION=2.3.0-0
RUN luarocks install kong-datadog-k8s $PLUGIN_ROCK_VERSION
