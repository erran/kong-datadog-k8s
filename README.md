# kong-datadog-k8s
A fork of the bundled datadog plugin which supports passing host as an environment variable

## Developing
Build the docker image locally (you can use the .dev variant if you'd like to validate local changes).
```
docker build -f Dockerfile.dev \
  -t kong-k8s:0.14.1 .
```

Create and bootstrap a postgres container to use.
```
docker run -d -it --name kong-database \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  -e "POSTGRES_HOST_AUTH_METHOD=trust" \
  postgres:9.6
docker run -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=docker.for.mac.localhost \
  kong-k8s:0.14.1 -- kong migrations up
```

Run kong locally:
```
docker run -d -it --name kong-k8s \
  -p 8000-8001:8000-8001 \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -e KONG_DATABASE=postgres \
  -e KONG_DATADOG_K8S_HOST=docker.for.mac.localhost \
  -e KONG_NGINX_CONF=/usr/local/kong/custom_nginx.template \
  -e KONG_NGINX_MAIN_ENV=KONG_DATADOG_K8S_HOST \
  -e KONG_PG_HOST=docker.for.mac.localhost \
  -e KONG_PLUGINS=bundled,datadog-k8s \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  kong-k8s:0.14.1
```

Create Services/Routes to verify the plugin:
```
http POST localhost:8001/services name=example url=https://httpbin.org/anything
http POST localhost:8001/services/example/routes paths:='["/example"]' > route.json
http POST localhost:8001/plugins route_id=$(jq -r .id route.json) name=datadog-k8s
http localhost:8000/example
```

Verify the [mock] dd agent receives requests
```
docker logs
```

To verify custom environment variable names you must update [custom_nginx.template](./custom_nginx.template)
to call `env YOUR_VAR_NAME` and set the appropriate variable in your container's environment. Note that this
requires re-building the docker image.
