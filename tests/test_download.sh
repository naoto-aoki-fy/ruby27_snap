#!/bin/bash
set -euo pipefail

ARCH=$(dpkg --print-architecture)
INFO=$(../snap/snap_download.sh ruby 2.7/stable "$ARCH" test_dl)
SNAP_PATH=$(echo "$INFO" | awk -F= '/^SNAP=/ {print $2}')
ASSERT_PATH=$(echo "$INFO" | awk -F= '/^ASSERT=/ {print $2}')

if [ -f "$SNAP_PATH" ] && [ -f "$ASSERT_PATH" ]; then
  echo "download: ok"
else
  echo "download: failed" >&2
  exit 1
fi
