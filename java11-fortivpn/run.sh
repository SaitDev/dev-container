docker run --rm -it \
  --device=/dev/net/tun \
  --device=/dev/ppp \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --mount type=volume,source=dind-runtime,target=/var/run/dind \
  -e DOCKER_HOST=unix:///var/run/dind/docker.sock \
  --env-file .env \
  java11-fortivpn:latest
