#!/bin/bash
set -euo pipefail

ARCH=$(dpkg --print-architecture)

# test snap_download.sh
INFO=$(./snap_download.sh ruby 2.7/stable "$ARCH" test_dl)
SNAP_PATH=$(echo "$INFO" | awk -F= '/^SNAP=/ {print $2}')
ASSERT_PATH=$(echo "$INFO" | awk -F= '/^ASSERT=/ {print $2}')
[ -f "$SNAP_PATH" ] && [ -f "$ASSERT_PATH" ]

# test snap_install.sh
INSTALL_INFO=$(./snap_install.sh "$ASSERT_PATH" "$SNAP_PATH" test_inst)
TARGET_DIR=$(echo "$INSTALL_INFO" | awk -F= '/^TARGET_DIR=/ {print $2}')
[ -x "$TARGET_DIR/bin/ruby" ]

# test setup.sh
sudo ./setup.sh
[ -x /snap/ruby/current/bin/ruby ]

# source activate.sh and check ruby
source ./activate.sh
ruby --version | grep -q "2.7"

# check openssl
ruby -ropenssl -e 'puts :ok'

# deactivate and confirm ruby path changed
source ./deactivate.sh
if [ "$(which ruby)" = "/snap/ruby/current/bin/ruby" ]; then
  echo "ruby path not restored" >&2
  exit 1
fi

exit 0
