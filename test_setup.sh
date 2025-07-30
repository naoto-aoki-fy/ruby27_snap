#!/bin/bash
set -euo pipefail

sudo ./setup.sh

if [ -x /snap/ruby/current/bin/ruby ]; then
  echo "setup: ok"
else
  echo "setup: failed" >&2
  exit 1
fi
