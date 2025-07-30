#!/bin/bash

set -euo pipefail

# Skip apt operations when all required packages are installed
PACKAGES=(squashfs-tools curl jq)
MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  apt-get update
  apt-get install -y "${MISSING[@]}"
fi

SNAP_FILE="ruby27.snap"
SNAP_DIR="/opt/ruby27"

if [ ! -f "$SNAP_FILE" ]; then
  ./snap_download.sh ruby 2.7/stable "$(dpkg --print-architecture)" "$SNAP_FILE"
fi

if [ ! -d "$SNAP_DIR" ]; then
  unsquashfs -d "$SNAP_DIR" "$SNAP_FILE"
fi

mkdir -p /snap/core20/current/lib64
ln -sf /lib64/ld-linux-x86-64.so.2 /snap/core20/current/lib64/ld-linux-x86-64.so.2
