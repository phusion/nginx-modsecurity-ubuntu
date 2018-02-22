#!/bin/bash
set -e
# --privileged is to make bindfs work in the container
exec docker run -t -i --rm --init --privileged \
	-e APP_UID="$(id -u)" \
	-e APP_GID="$(id -g)" \
	-v "$(pwd):/host.real" \
	phusion/libnginx-mod-http-modsecurity-builder:latest \
	sudo -u app -H bash
