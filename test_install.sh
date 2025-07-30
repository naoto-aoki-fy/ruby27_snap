#!/bin/bash
set -euo pipefail

ARCH=$(dpkg --print-architecture)
INFO=$(./snap_download.sh ruby 2.7/stable "$ARCH" test_inst_dl)
SNAP_PATH=$(echo "$INFO" | awk -F= '/^SNAP=/ {print $2}')
ASSERT_PATH=$(echo "$INFO" | awk -F= '/^ASSERT=/ {print $2}')

INSTALL_INFO=$(./snap_install.sh "$ASSERT_PATH" "$SNAP_PATH" test_inst)
TARGET_DIR=$(echo "$INSTALL_INFO" | awk -F= '/^TARGET_DIR=/ {print $2}')

if [ -x "$TARGET_DIR/bin/ruby" ]; then
  echo "install: ok"
else
  echo "install: failed" >&2
  exit 1
fi
