#!/bin/bash
set -euo pipefail

source ./activate.sh
ruby --version | grep -q "2.7"
ruby -ropenssl -e 'puts :ok'

deactivate
if [ "$(which ruby)" = "/snap/ruby/current/bin/ruby" ]; then
  echo "activate: failed" >&2
  exit 1
else
  echo "activate: ok"
fi
