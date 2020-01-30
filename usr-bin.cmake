#!/usr/bin/env bash
set -eu

cd "/usr/lib/rakuma-ops/@VERSION@/app"
exec nodejs ./src/index.js >> /tmp/rakuma-ops/output.log
