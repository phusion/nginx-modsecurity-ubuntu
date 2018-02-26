#!/bin/bash
set -e
set -o pipefail

export LC_ALL=C.UTF-8
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=3
export PATH=/usr/lib/ccache:$PATH

if [[ $# -gt 0 ]]; then
	exec "$@"
fi
