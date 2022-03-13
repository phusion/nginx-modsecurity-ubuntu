#!/usr/bin/env bash
set -e
VERSION=$(cat dev-container/VERSION.txt)
exec docker run -t -i --rm --init \
	--user "$(id -u):$(id -g)" \
	-v "$(pwd):/host:delegated" \
	"phusion/nginx-modsecurity-ubuntu-builder:$VERSION" \
	/bin/sh -c 'cd /host && exec bash -l'
