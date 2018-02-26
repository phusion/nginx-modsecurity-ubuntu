#!/bin/bash
set -e
exec docker build --force-rm -t phusion/nginx-modsecurity-ubuntu-builder:latest docker-env
