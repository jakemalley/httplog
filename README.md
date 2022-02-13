# httplog
simple golang container for testing Kubernetes deployments and presenting '200 OK' healthchecks

## building
### building with `buildah`

```
buildah unshare ./build_with_buildah.sh
```

### building with `buildah` using a Dockerfile

```
buildah bud -f Dockerfile -t docker.io/jakemalley/httplog:latest .
```

### building with `podman`/`docker`

```
podman build -f Dockerfile -t docker.io/jakemalley/httplog:latest .
```

## running

```
podman run --rm --name httplog -p "8888:8888" docker.io/jakemalley/httplog:latest
```
