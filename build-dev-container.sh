#!/usr/bin/env bash
set -ex
VERSION=$(cat dev-container/VERSION.txt)
exec docker build --force-rm -t "phusion/nginx-modsecurity-ubuntu-builder:$VERSION" dev-container
