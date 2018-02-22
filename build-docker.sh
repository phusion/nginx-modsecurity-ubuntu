#!/bin/bash
set -e
exec docker build --force-rm -t phusion/libnginx-mod-http-modsecurity-builder:latest docker-env
