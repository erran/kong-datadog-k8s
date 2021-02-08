# kong-datadog-k8s
[![][LuaRocks latest version badge]](http://luarocks.org/modules/erran/kong-datadog-k8s)
[![][LuaRocks 0.14.1-0 badge]](http://luarocks.org/modules/erran/kong-datadog-k8s/0.14.1-0)

A fork of the bundled datadog plugin which supports passing host as an environment variable.

## Developing
Build the docker image locally (you can use the .dev variant if you'd like to validate local changes).
```
docker build -f Dockerfile.dev \
  --build-arg PLUGIN_ROCK_VERSION=2.3.0-0 \
  -t kong-k8s:2.3.0 .
```

Run kong locally:
```
docker run --name kong-k8s \
  -p 8000-8001:8000-8001 \
  -e KONG_DATABASE=off \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -v $(pwd)/declarative-config:/usr/local/kong/declarative \
  -e KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml \
  -e KONG_PLUGINS=bundled,datadog-k8s \
  -e KONG_NGINX_MAIN_ENV=KONG_DATADOG_K8S_HOST \
  -e KONG_DATADOG_K8S_HOST=docker.for.mac.localhost \
  -e KONG_NGINX_EVENTS_MULTI_ACCEPT=off kong-k8s:2.3.0
```

Call Services/Routes defined in [./declarative-config][] to verify the plugin:
```
http localhost:8000/example
```

Verify the [mock] dd agent receives requests
```
docker logs
```

To verify custom environment variable names you must:
1. Inject the `env` Nginx directive in your container environment (e.g. `-e KONG_NGINX_MAIN_ENV=KONG_DATADOG_K8S_HOST`).
2. Overwrite the `config.host_from_env` option to match this value.

If you must support more than one environment variable being exposed to worker processes you'll need to use a custom nginx template as documented by Kong and [demonstrated in the 0.14.x branch of this project](https://github.com/erran/kong-datadog-k8s/tree/0.14.x).

[LuaRocks latest version badge]: https://img.shields.io/luarocks/v/erran/kong-datadog-k8s?label=luarocks%20%28latest%20version%29 "LuaRocks Latest"
[LuaRocks 0.14.1-0 badge]: https://img.shields.io/luarocks/v/erran/kong-datadog-k8s/0.14.1-0 "LuaRocks 0.14.1-0"
[LuaRocks 2.3.0-0 badge]: https://img.shields.io/luarocks/v/erran/kong-datadog-k8s/2.3.0-0 "LuaRocks Latest"
