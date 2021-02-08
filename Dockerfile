FROM kong:2.3-alpine

USER root
RUN luarocks install kong-datadog-k8s
USER kong
