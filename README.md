# kong-datadog-k8s
A fork of the bundled datadog plugin which supports passing host as an environment variable

Build the docker image locally (you can use the .dev variant if you'd like to validate local changes).

```
docker run -d -it --name kong-database \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  -e "POSTGRES_HOST_AUTH_METHOD=trust" \
  postgres:9.6

docker run -d -it --name kong-k8s -p 8000-8001:8000-8001 \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=docker.for.mac.localhost \
  -e KONG_PLUGINS=bundled,datadog-k8s \
  -e KONG_NGINX_MAIN_ENV=KONG_DATADOG_K8S_HOST \
  -e KONG_DATADOG_K8S_HOST=docker.for.mac.localhost \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  kong-k8s:0.14.1
```

```
http POST localhost:8001/services name=example url=https://httpbin.org/anything
http POST localhost:8001/services/example/routes paths:='["/example"]' > route.json
http POST localhost:8001/plugins route_id=$(jq -r .id route.json) name=datadog-k8s
http localhost:8000/example
# verify the [mock] dd agent receives requests
```
